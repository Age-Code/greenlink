class SignupRequest {
  final String email;
  final String password;
  final String nickname;
  SignupRequest({required this.email, required this.password, required this.nickname});
  Map<String, dynamic> toJson() => {'email': email, 'password': password, 'nickname': nickname};
}

class SignupResponse {
  final int userId;
  final String nickname;
  final List<GrantedItem> grantedItems;
  SignupResponse({required this.userId, required this.nickname, required this.grantedItems});
  factory SignupResponse.fromJson(Map<String, dynamic> json) => SignupResponse(
    userId: json['userId'] ?? 0,
    nickname: json['nickname'] ?? '',
    grantedItems: (json['grantedItems'] as List?)?.map((i) => GrantedItem.fromJson(i)).toList() ?? [],
  );
}

class GrantedItem {
  final int userItemId;
  final String name;
  final String itemType;
  final String? imageUrl;
  GrantedItem({required this.userItemId, required this.name, required this.itemType, this.imageUrl});
  factory GrantedItem.fromJson(Map<String, dynamic> json) => GrantedItem(
    userItemId: json['userItemId'] ?? 0,
    name: json['name'] ?? '',
    itemType: json['itemType'] ?? '',
    imageUrl: json['imageUrl'],
  );
}

class LoginRequest {
  final String email;
  final String password;
  LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final LoginUser user;
  LoginResponse({required this.accessToken, required this.tokenType, required this.user});
  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json['accessToken'] ?? '',
    tokenType: json['tokenType'] ?? 'Bearer',
    user: LoginUser.fromJson(json['user']),
  );
}

class LoginUser {
  final int userId;
  final String email;
  final String nickname;
  LoginUser({required this.userId, required this.email, required this.nickname});
  factory LoginUser.fromJson(Map<String, dynamic> json) => LoginUser(
    userId: json['userId'] ?? 0,
    email: json['email'] ?? '',
    nickname: json['nickname'] ?? '',
  );
}
