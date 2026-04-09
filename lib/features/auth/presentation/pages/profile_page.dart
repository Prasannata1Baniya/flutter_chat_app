import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cubits/auth-cubit/auth_cubit.dart';
import '../cubits/auth-cubit/auth_state.dart';
import 'dart:typed_data';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Uint8List? _webImage;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  // 1. Load the image from browser storage on startup
  Future<void> _loadSavedImage() async {
    final user = context.read<AuthCubit>().currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String? base64String = prefs.getString('profile_image_${user.uid}');

    if (base64String != null) {
      setState(() {
        _webImage = base64Decode(base64String);
      });
    }
  }

  // 2. Pick and Save locally
  Future<void> _pickImage() async {
    final user = context.read<AuthCubit>().currentUser;
    if (user == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      imageQuality: 50,
    );

    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();
      final prefs = await SharedPreferences.getInstance();

      // CHANGE: Use the UID in the key
      String base64String = base64Encode(bytes);
      await prefs.setString('profile_image_${user.uid}', base64String);

      setState(() {
        _webImage = bytes;
      });
    }
  }

  void _showEditDialog(BuildContext context, String currentName) {
    final TextEditingController nameController =
    TextEditingController(text: currentName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit Your Name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                hintText: "Enter your name",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AuthCubit>().updateName(nameController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile Updated!")),
                );
              },

              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Save Changes",
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:
        const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = context.read<AuthCubit>().currentUser;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                          Border.all(color: Colors.blue.shade100, width: 5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: ()=> _pickImage(),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.blue.shade500,
                              backgroundImage: _webImage != null
                                  ? MemoryImage(_webImage!)
                                  : null,
                              child: _webImage == null
                                  ? Text(
                                user?.name?[0].toUpperCase() ?? 'U',
                                style: const TextStyle(color: Colors.white, fontSize: 40),
                              )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue.shade700,
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 15),
                Text(
                  user?.name ?? 'No Name',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Available",
                  style: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoTile(Icons.person_outline, "Full Name",
                                user?.name ?? 'Not set'),
                            const Divider(height: 1, indent: 60),
                            _buildInfoTile(Icons.email_outlined, "Email Address",
                                user?.email ?? 'Not set'),
                            const Divider(height: 1, indent: 60),
                            _buildInfoTile(
                                Icons.phone_outlined, "Phone", "+1 234 567 890"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),


                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                _showEditDialog(context, user?.name ?? ''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 0,
                            ),
                            child: const Text("Edit Profile",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              context.read<AuthCubit>().logOut();
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red.shade300),
                              foregroundColor: Colors.red.shade600,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Text("Log Out",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue.shade700, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
