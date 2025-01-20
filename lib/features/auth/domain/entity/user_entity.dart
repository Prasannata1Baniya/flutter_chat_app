class UserEntity{
 final String uid;
  final String? name;
  final  String email;
  UserEntity({required this.uid,required this.name,
    required this.email,
  });

  //->toJSON
   Map<String,dynamic> toJson(){
     return {
       'uid':uid,
       'name':name,
       'email':email,
     };
   }

   factory UserEntity.fromJson(Map<String,dynamic> json){
     return UserEntity(
         uid: json['uid'],
         name: json['name'],
         email: json['email']);
   }

 factory UserEntity.fromMap(Map<String, dynamic> map) {
   return UserEntity(
     uid: map['uid'],
     name: map['name'],
     email: map['email'],
   );
 }
}