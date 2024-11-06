import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remisse_arequipa_driver/models/user_model.dart';
import 'package:remisse_arequipa_driver/services/auth_service.dart';
import 'package:remisse_arequipa_driver/methods/common_methods.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignupViewmodel extends ChangeNotifier 
{
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String? errorMessage;
  UserModel? user;
  XFile? profileImage;
  int currentPage = 0;
  final CommonMethods cMethods = CommonMethods();
  final PageController pageController = PageController();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;


  Future<void> signUp(String email, String password, String name, String phone, String carModel, String carColor, String carPlate, XFile perfilPhoto) async
  {
    isLoading= true;
    notifyListeners();
    try
    {
      final imageUrl = await uploadImageToFirebase(perfilPhoto);


      user = await _authService.signUpUser(email, password, name, phone, carModel, carColor, carPlate, imageUrl);
      errorMessage = null;
    }catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }

  }

  Future<void> chooseImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage = pickedFile;
      notifyListeners();
    }
  }

  Future<String> uploadImageToFirebase(XFile imageFile) async {
    try {
      final storageRef = _firebaseStorage.ref().child('profileImages/${imageFile.name}');
      final uploadTask = await storageRef.putFile(File(imageFile.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Error al subir la imagen: $e");
    }
  }
}