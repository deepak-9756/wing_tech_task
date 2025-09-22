// models/asset_model.dart
class Asset {
  final String id;
  final String name;
  final String category;
  final String qrCode;
  final String? assignedTo;
  final String? assignedEmail;
  final DateTime? checkOutDate;
  final DateTime? expectedReturnDate;
  final bool isAvailable;
  final DateTime createdAt;
  final String createdBy;

  Asset({
    required this.id,
    required this.name,
    required this.category,
    required this.qrCode,
    this.assignedTo,
    this.assignedEmail,
    this.checkOutDate,
    this.expectedReturnDate,
    required this.isAvailable,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'qrCode': qrCode,
      'assignedTo': assignedTo,
      'assignedEmail': assignedEmail,
      'checkOutDate': checkOutDate?.millisecondsSinceEpoch,
      'expectedReturnDate': expectedReturnDate?.millisecondsSinceEpoch,
      'isAvailable': isAvailable,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'createdBy': createdBy,
    };
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      qrCode: json['qrCode'],
      assignedTo: json['assignedTo'],
      assignedEmail: json['assignedEmail'],
      checkOutDate: json['checkOutDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['checkOutDate'])
          : null,
      expectedReturnDate: json['expectedReturnDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expectedReturnDate'])
          : null,
      isAvailable: json['isAvailable'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      createdBy: json['createdBy'],
    );
  }
}
