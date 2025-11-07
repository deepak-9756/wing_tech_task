import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'package:image_picker/image_picker.dart';

class UserProvider extends ChangeNotifier {
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  UserModel? _user;
  List<UserModel> _allEmployees = []; // ← YE ADD KIYA
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  List<UserModel> get allEmployees => _allEmployees; // ← YE ADD KIYA
  int get employeeCount => _allEmployees.length; // ← YE ADD KIYA
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUser(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _firestoreService.getUserProfile(uid);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUserProfile({
    required String uid,
    required String name,
    String? department,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        name: name,
        department: department,
        phone: phone,
      );

      await _firestoreService.updateUserProfile(uid, updatedUser);
      _user = updatedUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadProfileImage(String uid, XFile imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final imageUrl = await _storageService.uploadProfileImage(
        uid: uid,
        imageFile: imageFile,
      );

      final updatedUser = _user!.copyWith(profileImageUrl: imageUrl);
      await _firestoreService.updateUserProfile(uid, updatedUser);
      _user = updatedUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print("error here ${_error}");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ← YE PURA FUNCTION UPDATE KIYA
  Future<void> getAllEmployees() async {
    _isLoading = true;
    _error = null;

    try {
      _allEmployees = await _firestoreService.getAllEmployees();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
}
