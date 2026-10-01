class LoginRequest {
  final String email;
  final String password;
  
  LoginRequest({
    required this.email,
    required this.password,
  });
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class LoginResponse {
  final bool success;
  final AuthData? data;
  final String? message;
  
  LoginResponse({
    required this.success,
    this.data,
    this.message,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    success: json['success'] as bool,
    data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    message: json['message'] as String?,
  );
}

// Backend response structure (match web portal)
class AuthData {
  final String token;
  final String? refreshToken;
  final String tokenType;
  final int userId;
  final String email;
  final String role;
  final String status;
  final bool? emailVerified;
  
  AuthData({
    required this.token,
    this.refreshToken,
    required this.tokenType,
    required this.userId,
    required this.email,
    required this.role,
    required this.status,
    this.emailVerified,
  });
  
  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
    token: json['token'] as String,
    refreshToken: json['refreshToken'] as String?,
    tokenType: json['tokenType'] as String? ?? 'Bearer',
    userId: json['userId'] as int,
    email: json['email'] as String,
    role: json['role'] as String,
    status: json['status'] as String,
    emailVerified: json['emailVerified'] as bool?,
  );
  
  Map<String, dynamic> toJson() => {
    'token': token,
    'refreshToken': refreshToken,
    'tokenType': tokenType,
    'userId': userId,
    'email': email,
    'role': role,
    'status': status,
    'emailVerified': emailVerified,
  };
}

// User data model (can be removed if not used separately)
class UserData {
  final int id;
  final String email;
  final String name;
  final String role;
  final String? avatar;
  
  UserData({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatar,
  });
  
  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json['id'] as int,
    email: json['email'] as String,
    name: json['name'] as String,
    role: json['role'] as String,
    avatar: json['avatar'] as String?,
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'avatar': avatar,
  };
}

class RegisterRequest {
  final String email;
  final String password;
  final String confirmPassword;
  final String role; // ENTERPRISE or TALENT
  
  RegisterRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'confirmPassword': confirmPassword,
    'role': role,
  };
}
