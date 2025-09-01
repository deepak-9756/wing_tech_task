class Customer {
  final int id;
  final String login;
  final String avatarUrl;
  final String url;
  bool isFollowed;
  String? followedBy;
  DateTime? followedAt;

  Customer({
    required this.id,
    required this.login,
    required this.avatarUrl,
    required this.url,
    this.isFollowed = false,
    this.followedBy,
    this.followedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      login: json['login'],
      avatarUrl: json['avatar_url'],
      url: json['url'],
    );
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      login: map['login'],
      avatarUrl: map['avatar_url'],
      url: map['url'],
      isFollowed: map['is_followed'] == 1,
      followedBy: map['followed_by'],
      followedAt:
          map['followed_at'] != null
              ? DateTime.parse(map['followed_at'])
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'login': login,
      'avatar_url': avatarUrl,
      'url': url,
      'is_followed': isFollowed ? 1 : 0,
      'followed_by': followedBy,
      'followed_at': followedAt?.toIso8601String(),
    };
  }
}
