import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  const CustomSearchBar({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      //padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20),
          side: const BorderSide(color: Colors.black54,width: 0.5),
        ),
        child: SizedBox(
          width: 450,
          height: 42,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              focusedBorder:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(
                    width: 1, color: Colors.lightBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              hintText: "Search friends...",
              hintStyle: TextStyle(color: Colors.grey.shade500,
                  fontSize: 15),
              prefixIcon: Icon(Icons.search_rounded, color: Colors
                  .grey.shade600, size: 22),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () =>searchController.clear(),
              )
                  : null,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}