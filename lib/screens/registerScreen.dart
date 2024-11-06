import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:task1/providers/apiProvider.dart';
import 'package:task1/providers/storageProvider.dart';
import 'package:task1/screens/bottomNavScreen.dart';
import 'package:task1/screens/homeScreen.dart';

import '../widgets/user_image_picker.dart';
import 'loginScreen.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  static const routeName = '/sign-up';


  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String user_name = '';
  String _userEmail = '';
  String _userPassword = '';
  var _isLoading = false;
  File? _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _submit() async {
    final storageProvider = Provider.of<StorageProvider>(context,listen: false);
    final apiProvider = Provider.of<ApiProvider>(context,listen: false);

    setState(() {
      _isLoading = true;
    });

    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    print('working');
    if (_userImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please pick an Image"),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      if (isValid) {
        _formKey.currentState!.save();
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );
        // upload image to cloud
        final imageUrl = await storageProvider.uploadImageToCloudinary(_userImageFile!);
        if (imageUrl != null) {
          print('Image url: $imageUrl');
        }

        print("called here");
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'name': user_name,
          'email': _userEmail,
          'image': imageUrl,
        });
        print("called here 2");
        await apiProvider.getUserDetailsByUuid();
        Navigator.of(context).pushReplacementNamed(BottomNavScreen.routeName);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 10,
            ),
            Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Register",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                    Align(
                      alignment: Alignment.center,
                      child: UserImagePicker(_pickedImage),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.add_business),
                          hintText: 'Name',
                          hintStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          fillColor: Color(0xFFEEEEEE),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSaved: (value) {
                          user_name = value!;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Please enter valid email address. eg. abc@xvz.com';
                          }
                          return null;
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: 'Email (eg. abc@xyz.com)',
                          hintStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          fillColor: Color(0xFFEEEEEE),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSaved: (value) {
                          _userEmail = value!;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty || value.length < 7) {
                            return 'Password too short';
                          }
                          return null;
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            size: 25,
                          ),
                          hintText: 'Password',
                          hintStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          fillColor: Color(0xFFEEEEEE),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSaved: (value) {
                          _userPassword = value!;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    if (_isLoading)
                      Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                    if (!_isLoading)
                    GestureDetector(
                      onTap: ()async{
                        _submit();
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                            width: size.width * 0.9,
                            height: 45,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(30),

                            ),
                            child: Text("REGISTER",style: TextStyle(color: Colors.white),)
                        ),
                      ),
                    ),
                    if (!_isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already a user?",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          TextButton(
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(LoginScreen.routeName);
                            },
                          ),
                        ],
                      ),
                  ],
                ))
          ]),
        ),
      ),
    );
  }
}
