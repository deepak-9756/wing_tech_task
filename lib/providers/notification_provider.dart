import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => _notifications;

  void startListening() {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            NotificationService.showNotification(
              id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
              title: 'Customer Follow-up',
              body: '${data['employeeEmail']} has followed up with customers',
            );
          }

          _notifications =
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              }).toList();

          notifyListeners();
        });
  }

  Future<void> markAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}
