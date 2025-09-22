// services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wing_tech_task/models/assets_model.dart';
 
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add Asset
  Future<void> addAsset(Asset asset) async {
    await _firestore.collection('assets').doc(asset.id).set(asset.toJson());
  }

  // Get All Assets
  Stream<List<Asset>> getAssets() {
    return _firestore
        .collection('assets')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Asset.fromJson(doc.data()))
            .toList());
  }

  // Check Out Asset
  Future<void> checkOutAsset(String assetId, String userName, String userEmail, 
      DateTime expectedReturn) async {
    await _firestore.collection('assets').doc(assetId).update({
      'assignedTo': userName,
      'assignedEmail': userEmail,
      'checkOutDate': DateTime.now().millisecondsSinceEpoch,
      'expectedReturnDate': expectedReturn.millisecondsSinceEpoch,
      'isAvailable': false,
    });

    // Add to transaction history
    await _addTransaction(assetId, 'CHECK_OUT', userName);
  }

  // Check In Asset
  Future<void> checkInAsset(String assetId) async {
    await _firestore.collection('assets').doc(assetId).update({
      'assignedTo': null,
      'assignedEmail': null,
      'checkOutDate': null,
      'expectedReturnDate': null,
      'isAvailable': true,
    });

    // Add to transaction history
    await _addTransaction(assetId, 'CHECK_IN', _auth.currentUser?.displayName ?? 'Unknown');
  }

  // Add Transaction History
  Future<void> _addTransaction(String assetId, String action, String userName) async {
    await _firestore.collection('transactions').add({
      'assetId': assetId,
      'action': action,
      'userName': userName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Get Overdue Assets
  Stream<List<Asset>> getOverdueAssets() {
    return _firestore
        .collection('assets')
        .where('isAvailable', isEqualTo: false)
        .where('expectedReturnDate', isLessThan: DateTime.now().millisecondsSinceEpoch)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Asset.fromJson(doc.data()))
            .toList());
  }
}
