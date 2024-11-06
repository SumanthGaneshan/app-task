import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:task1/models/productsResponse.dart';
import 'package:task1/noti/firebaseApi.dart';

class ApiProvider with ChangeNotifier{

  FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> userDetails = {};

  List<Product> products = [];

  List<Product> _likedProducts = [];

  List<Product> get likedProducts => _likedProducts;

  ApiProvider() {
    getProducts();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _likedProducts.clear();
        userDetails.clear();
      } else {
        setUser();
        _fetchLikedProducts();
        getUserDetailsByUuid();
      }
    });
  }

  Future<void> getProducts({String? searchQuery}) async {
    try {
      String url = 'https://dummyjson.com/products';
      if (searchQuery != null && searchQuery.isNotEmpty) {
        url += '/search?q=$searchQuery';
      }

      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        var decodedData = jsonDecode(response.body);
        var data = ProductResponse.fromJson(decodedData);
        products = data.products;
      } else {
        print("Failed to load products. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Something went wrong: $e");
    }
    notifyListeners();
  }

  Future<void> _fetchLikedProducts() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userLikes = await _firestore.collection('likes').doc(userId).get();

    if (userLikes.exists) {
      final likedProductsData = Map<String, dynamic>.from(userLikes.data() as Map<String,dynamic>);
      _likedProducts = ProductResponse.fromJson(likedProductsData).products ?? [];
      notifyListeners();
    }
  }

  Future<void> toggleLike(Product product) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userLikesRef = _firestore.collection('likes').doc(userId);

    if (_likedProducts.any((p) => p.id == product.id)) {
      _likedProducts.removeWhere((p) => p.id == product.id);
    } else {
      _likedProducts.add(product);
    }

    await userLikesRef.set({
      'products': _likedProducts.map((p) => p.toJson()).toList(),
    });

    notifyListeners();
  }

  bool isLiked(Product product) {
    return _likedProducts.any((p) => p.id == product.id);
  }

  Future<void> setUser() async{
    if(FirebaseAuth.instance.currentUser != null){
      _auth = FirebaseAuth.instance;
      notifyListeners();
    }
  }


  Future<void> getUserDetailsByUuid() async {
    try {

      if(_auth.currentUser != null){
        DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).get();

        if (documentSnapshot.exists) {
          userDetails = documentSnapshot.data() as Map<String, dynamic>;
        } else {
          print("No use");
        }
      }

    } catch (e) {
    }
    notifyListeners();
  }


  Future<void> updateUserDetails(String newName) async {
    EasyLoading.show();
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {

         await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': newName,
        });
        await getUserDetailsByUuid();

         await sendPushNotification(newName);
        print("User udpated");
      } else {
        print("No user");
      }
    } catch (e) {
      print(e);
    }
    EasyLoading.dismiss();
    notifyListeners();
  }

  Future<void> sendPushNotification(String newName) async {

    FirebaseApi().showNotification(
      'Name Updated',
      'Your name has been updated to: $newName',
    );
  }


}