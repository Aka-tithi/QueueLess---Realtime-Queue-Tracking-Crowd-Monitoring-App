class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String status;
  final int totalVisits;
  final double averageRating;
  final int favoriteCount;
  final List<String> favoriteLocationIds;
  final DateTime joinDate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.status,
    required this.totalVisits,
    required this.averageRating,
    required this.favoriteCount,
    required this.favoriteLocationIds,
    required this.joinDate,
  });

  /// Create UserModel from JSON (Supabase response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profile_image_url'] ?? '👤',
      status: json['status'] ?? 'Active',
      totalVisits: json['total_visits'] ?? 0,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      favoriteCount: json['favorite_count'] ?? 0,
      favoriteLocationIds: List<String>.from(
        json['favorite_location_ids'] ?? [],
      ),
      joinDate: json['join_date'] != null
          ? DateTime.parse(json['join_date'])
          : DateTime.now(),
    );
  }

  /// Convert UserModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImage,
      'status': status,
      'total_visits': totalVisits,
      'average_rating': averageRating,
      'favorite_count': favoriteCount,
      'favorite_location_ids': favoriteLocationIds,
      'join_date': joinDate.toIso8601String(),
    };
  }

  /// Create a copy of UserModel with optional field replacements
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? status,
    int? totalVisits,
    double? averageRating,
    int? favoriteCount,
    List<String>? favoriteLocationIds,
    DateTime? joinDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      status: status ?? this.status,
      totalVisits: totalVisits ?? this.totalVisits,
      averageRating: averageRating ?? this.averageRating,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      favoriteLocationIds: favoriteLocationIds ?? this.favoriteLocationIds,
      joinDate: joinDate ?? this.joinDate,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, phone: $phone, status: $status)';
  }
}

final UserModel mockUser = UserModel(
  id: 'user_001',
  name: 'Muhammad Hasan',
  email: 'hasan@example.com',
  phone: '+880 1700 000000',
  profileImage: '👤',
  status: 'Active',
  totalVisits: 24,
  averageRating: 4.2,
  favoriteCount: 8,
  favoriteLocationIds: ['1', '2', '4', '5'],
  joinDate: DateTime(2023, 6, 15),
);
