/// API Response Types (Match web portal structure)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String timestamp;
  
  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.timestamp,
  });
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
  
  Map<String, dynamic> toJson(Object? Function(T?)? toJsonT) => {
        'success': success,
        'message': message,
        'data': toJsonT != null ? toJsonT(data) : data,
        'timestamp': timestamp,
      };
}

/// API Error Response (Match web portal error structure)
class ApiError {
  final bool success;
  final String message;
  final Map<String, List<String>>? errors;
  final String timestamp;
  
  ApiError({
    this.success = false,
    required this.message,
    this.errors,
    required this.timestamp,
  });
  
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String,
      errors: json['errors'] != null
          ? (json['errors'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                (value as List).map((e) => e.toString()).toList(),
              ),
            )
          : null,
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
  
  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'errors': errors,
        'timestamp': timestamp,
      };
}

/// Pagination params (Match web portal)
class PaginationParams {
  final int page;
  final int size;
  final String? sort;
  final String? order; // 'asc' or 'desc'
  
  PaginationParams({
    required this.page,
    required this.size,
    this.sort,
    this.order,
  });
  
  Map<String, dynamic> toJson() => {
        'page': page,
        'size': size,
        if (sort != null) 'sort': sort,
        if (order != null) 'order': order,
      };
}

/// Paginated Response (Match web portal)
class PaginatedResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;
  final bool first;
  
  PaginatedResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.first,
  });
  
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      content: (json['content'] as List)
          .map((item) => fromJsonT(item))
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      last: json['last'] as bool,
      first: json['first'] as bool,
    );
  }
  
  Map<String, dynamic> toJson(Object? Function(T)? toJsonT) => {
        'content': toJsonT != null
            ? content.map((item) => toJsonT(item)).toList()
            : content,
        'page': page,
        'size': size,
        'totalElements': totalElements,
        'totalPages': totalPages,
        'last': last,
        'first': first,
      };
}
