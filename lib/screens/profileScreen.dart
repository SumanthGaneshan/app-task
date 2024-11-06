import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task1/screens/registerScreen.dart';

import '../providers/apiProvider.dart';
import '../widgets/user_image_picker.dart';


class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApiProvider>(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: (){
              openEditProfileModal(context,provider.userDetails["name"] ?? "");
            },
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Edit",style: TextStyle(fontSize: 14,color: Colors.white),),
                    const SizedBox(width: 5),
                    Icon(Icons.edit,size: 14,color: Colors.white,),
                  ],
                ),
              ),
            ),
          ),
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              provider.userDetails["image"],
            ),
          ),
          SizedBox(height: 16,width: double.infinity,),
          profileTile(Icons.account_circle,provider.userDetails["name"] ?? ""),
          profileTile(Icons.mail,provider.userDetails["email"] ?? ""),

        GestureDetector(
          onTap: ()async{
            await FirebaseAuth.instance.signOut();
            // Navigator.of(context).pushReplacementNamed(RegisterScreen.routeName);
          },
          child: Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green[200],
              borderRadius: BorderRadius.circular(10),

            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Logout"),
                Icon(Icons.arrow_forward_ios)
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget profileTile(IconData icon,String text){
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        
      ),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 10,),
          Text(text),
        ],
      ),
    );
  }

  void openEditProfileModal(BuildContext context, String name) {
    TextEditingController nameController = TextEditingController(text: name);
    final provider = Provider.of<ApiProvider>(context,listen: false);


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Edit Details"),
            const SizedBox(height: 20,),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle),
                hintText: 'Name',
                hintStyle: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                fillColor: Color(0xFFEEEEEE),
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: (){
                provider.updateUserDetails(nameController.text).then((_){
                  Navigator.pop(context);
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(30),

                ),
                child: Text('Save',style: TextStyle(color: Colors.white),)
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

}