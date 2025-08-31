import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String recipeId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double rating; // 1-5 estrellas
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> likedBy;
  final bool isVisible;

  Review({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
    this.likedBy = const [],
    this.isVisible = true,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Manejo seguro de timestamps
    DateTime createdAt = DateTime.now();
    DateTime updatedAt = DateTime.now();
    
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        createdAt = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
      }
    }
    
    if (data['updatedAt'] != null) {
      if (data['updatedAt'] is Timestamp) {
        updatedAt = (data['updatedAt'] as Timestamp).toDate();
      } else if (data['updatedAt'] is String) {
        updatedAt = DateTime.tryParse(data['updatedAt']) ?? DateTime.now();
      }
    }
    
    return Review(
      id: doc.id,
      recipeId: data['recipeId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      createdAt: createdAt,
      updatedAt: updatedAt,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      isVisible: data['isVisible'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'likedBy': likedBy,
      'isVisible': isVisible,
    };
  }

  Review copyWith({
    double? rating,
    String? comment,
    List<String>? images,
    DateTime? updatedAt,
    List<String>? likedBy,
    bool? isVisible,
  }) {
    return Review(
      id: id,
      recipeId: recipeId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      likedBy: likedBy ?? this.likedBy,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}
