import 'package:cloud_firestore/cloud_firestore.dart';

class QRCodeModel {
  final String id;
  final String qrData;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final String createdBy;

  QRCodeModel({
    required this.id,
    required this.qrData,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
    required this.createdBy,
  });

  factory QRCodeModel.fromMap(Map<String, dynamic> map) {
    return QRCodeModel(
      id: map['id'] ?? '',
      qrData: map['qrData'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'qrData': qrData,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isActive': isActive,
      'createdBy': createdBy,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => isActive && !isExpired;
}
