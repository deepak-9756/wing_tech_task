// lib/controllers/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.snackbar('Success', 'Login successful!');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        default:
          message = 'Login failed. Please try again.';
      }
      Get.snackbar('Error', message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update user profile
      await userCredential.user?.updateDisplayName(name);
      
      Get.snackbar('Success', 'Account created successfully!');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        default:
          message = 'Registration failed. Please try again.';
      }
      Get.snackbar('Error', message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    Get.snackbar('Success', 'Logged out successfully');
  }
}
