import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/employee/employee_dashboard.dart';
import '../screens/login_screen.dart';

class AuthService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) async {
    if (user == null) {
      currentUser.value = null;
      Get.offAll(() => LoginScreen());
    } else {
      await _getUserData(user.uid);
    }
  }

  Future<void> _getUserData(String uid) async {
    try {
      isLoading.value = true;
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        currentUser.value = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        if (currentUser.value!.role == 'admin') {
          Get.offAll(() => AdminDashboard());
        } else {
          Get.offAll(() => EmployeeDashboard());
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to get user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> registerEmployee({
    required String email,
    required String password,
    required String name,
    required String employeeId,
    String role = 'employee',
    String? phone,
    String? department,
  }) async {
    try {
      isLoading.value = true;

      QuerySnapshot existingEmployee = await _firestore
          .collection('users')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      if (existingEmployee.docs.isNotEmpty) {
        return 'Employee ID already exists';
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          role: role,
          employeeId: employeeId,
          phone: phone,
          department: department,
          createdAt: DateTime.now(),
          isActive: true,
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        await user.sendEmailVerification();

        return null; // Success
      }
    } catch (e) {
      return e.toString();
    } finally {
      isLoading.value = false;
    }
    return 'Unknown error occurred';
  }

  Future<String?> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: email.trim(), 
        password: password.trim()
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'user-disabled':
          return 'User account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'invalid-email':
          return 'The email address is badly formatted.';
        default:
          return e.message ?? 'An error occurred during sign in.';
      }
    } catch (e) {
      return e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      currentUser.value = null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'invalid-email':
          return 'The email address is badly formatted.';
        default:
          return e.message ?? 'Failed to send reset email.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateProfile({
    required String name,
    String? phone,
    String? department,
  }) async {
    try {
      if (currentUser.value == null) return 'User not logged in';
      await _firestore.collection('users').doc(currentUser.value!.uid).update({
        'name': name,
        'phone': phone,
        'department': department,
      });

      currentUser.value = currentUser.value!.copyWith(
        name: name,
        phone: phone,
        department: department,
      );

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  bool get isLoggedIn => firebaseUser.value != null;
  bool get isAdmin => currentUser.value?.role == 'admin';
  bool get isEmployee => currentUser.value?.role == 'employee';
  String get userId => currentUser.value?.uid ?? '';
  String get userEmail => currentUser.value?.email ?? '';
  String get userName => currentUser.value?.name ?? '';
  String get employeeId => currentUser.value?.employeeId ?? '';
}
