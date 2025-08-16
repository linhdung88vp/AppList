import 'package:cloud_firestore/cloud_firestore.dart';

class Gara {
  final String? id;
  final String name;
  final String address;
  final String ownerName;
  final List<String> phoneNumbers;
  final List<String> imageUrls;
  final GeoPoint location; // Sử dụng GeoPoint của Firestore
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final String? createdBy; // ID của user tạo gara
  final String? createdByEmail; // Email của user tạo gara
  final String? createdByName; // Tên của user tạo gara

  Gara({
    this.id,
    required this.name,
    required this.address,
    required this.ownerName,
    required this.phoneNumbers,
    required this.imageUrls,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.createdBy,
    this.createdByEmail,
    this.createdByName,
  });

  Gara copyWith({
    String? id,
    String? name,
    String? address,
    String? ownerName,
    List<String>? phoneNumbers,
    List<String>? imageUrls,
    GeoPoint? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? createdBy,
    String? createdByEmail,
    String? createdByName,
  }) {
    return Gara(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      ownerName: ownerName ?? this.ownerName,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdByEmail: createdByEmail ?? this.createdByEmail,
      createdByName: createdByName ?? this.createdByName,
    );
  }

  /// Chuyển đổi từ Firestore Document
  factory Gara.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Gara(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      ownerName: data['ownerName'] ?? '',
      phoneNumbers: List<String>.from(data['phoneNumbers'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      location: data['location'] ?? const GeoPoint(0, 0),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      notes: data['notes'],
      createdBy: data['createdBy'],
      createdByEmail: data['createdByEmail'],
      createdByName: data['createdByName'],
    );
  }

  /// Chuyển đổi thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'ownerName': ownerName,
      'phoneNumbers': phoneNumbers,
      'imageUrls': imageUrls,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
      'createdBy': createdBy,
      'createdByEmail': createdByEmail,
      'createdByName': createdByName,
    };
  }

  /// Tạo gara mới với thời gian hiện tại
  factory Gara.create({
    required String name,
    required String address,
    required String ownerName,
    required List<String> phoneNumbers,
    required GeoPoint location,
    String? notes,
  }) {
    final now = DateTime.now();
    return Gara(
      name: name,
      address: address,
      ownerName: ownerName,
      phoneNumbers: phoneNumbers,
      imageUrls: [],
      location: location,
      createdAt: now,
      updatedAt: now,
      notes: notes,
    );
  }

  /// Chuyển đổi từ JSON (để tương thích với code cũ)
  factory Gara.fromJson(Map<String, dynamic> json) {
    return Gara(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      ownerName: json['ownerName'] ?? '',
      phoneNumbers: List<String>.from(json['phoneNumbers'] ?? []),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      location: json['location'] != null 
          ? GeoPoint(json['location']['latitude'] ?? 0.0, json['location']['longitude'] ?? 0.0)
          : const GeoPoint(0, 0),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      notes: json['notes'],
    );
  }

  /// Chuyển đổi thành JSON (để tương thích với code cũ)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'ownerName': ownerName,
      'phoneNumbers': phoneNumbers,
      'imageUrls': imageUrls,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'Gara(id: $id, name: $name, address: $address, ownerName: $ownerName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gara && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
