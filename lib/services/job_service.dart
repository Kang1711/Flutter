import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../objects/works.dart';

class JobService {
  final ApiClient _client = ApiClient();
  static const String _basePath =
      '/api/cong-viec/lay-danh-sach-cong-viec-theo-ten';

  Future<dynamic> searchJobsByName(String jobName) async {
    final encodedJobName = Uri.encodeComponent(jobName);
    final String path = '$_basePath/$encodedJobName';

    try {
      final response = await _client.get(path);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic>? jobListRaw =
            responseData['content'] as List<dynamic>?;

        if (jobListRaw != null) {
          return jobListRaw.cast<Map<String, dynamic>>();
        }
        return 'Không tìm thấy danh sách công việc.';
      }

      return response.data['message'] ??
          'Tìm kiếm thất bại. Mã: ${response.statusCode}';
    } on DioException catch (e) {
      if (kDebugMode) {
        print('JobService search error: ${e.message}');
      }

      if (e.response?.statusCode == 404) {
        return 'Không tìm thấy công việc phù hợp.';
      }
      if (e.response?.statusCode == 401) {
        return 'Lỗi xác thực.';
      }
      return 'Lỗi kết nối mạng.';
    } catch (e) {
      if (kDebugMode) {
        print('Unknown JobService error: $e');
      }
      return 'Lỗi không xác định.';
    }
  }
}

class JobCategoryService {
  final ApiClient _client = ApiClient();
  static const String _menuPath = '/api/cong-viec/lay-menu-loai-cong-viec';

  Future<dynamic> fetchJobMenu() async {
    try {
      final response = await _client.get(_menuPath);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic>? content =
            responseData['content'] as List<dynamic>?;

        if (content != null) {
          return content
              .map((item) =>
                  LoaiCongViec.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return 'Phản hồi không hợp lệ.';
      }

      return response.data['message'] ??
          'Lấy menu thất bại. Mã: ${response.statusCode}';
    } on DioException catch (e) {
      if (kDebugMode) {
        print('JobCategoryService error: ${e.message}');
      }
      return 'Lỗi kết nối mạng.';
    } catch (e) {
      if (kDebugMode) {
        print('Unknown JobCategoryService error: $e');
      }
      return 'Lỗi không xác định.';
    }
  }
}

class AuthService {
  final ApiClient _client = ApiClient();
  static const String _loginPath = '/api/auth/signin';

  Future<dynamic> signIn(String email, String password) async {
    try {
      final response =
          await _client.post(_loginPath, data: {'email': email, 'password': password});

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      return 'Đăng nhập thất bại.';
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 401) {
        return e.response?.data?['message'] ??
            'Email hoặc mật khẩu không đúng.';
      }
      return 'Lỗi kết nối mạng.';
    } catch (_) {
      return 'Lỗi không xác định.';
    }
  }
}

class AccountService {
  final ApiClient _client = ApiClient();
  static const String _signUpPath = '/api/auth/signup';

  Future<dynamic> signUp({
    required String account,
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _client.post(
        _signUpPath,
        data: {
          'account': account,
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'birthday': '2000-01-01',
          'gender': true,
          'role': 'USER',
          'skill': [],
          'certification': [],
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
      return 'Đăng ký thất bại.';
    } on DioException catch (e) {
      return e.response?.data['message'] ?? 'Lỗi đăng ký.';
    } catch (_) {
      return 'Lỗi không xác định.';
    }
  }
}

class CommentService {
  final ApiClient _client = ApiClient();
  static const String _basePath =
      '/api/binh-luan/lay-binh-luan-theo-cong-viec';

  Future<dynamic> fetchCommentsByJobId(int maCongViec) async {
    try {
      final response = await _client.get('$_basePath/$maCongViec');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic>? content =
            responseData['content'] as List<dynamic>?;

        if (content != null) {
          return BinhLuan.fromJsonList(content);
        }
        return 'Không có bình luận.';
      }

      return response.data['message'] ?? 'Lấy bình luận thất bại.';
    } on DioException catch (e) {
      if (kDebugMode) {
        print('CommentService error: ${e.message}');
      }
      return 'Lỗi kết nối mạng.';
    } catch (_) {
      return 'Lỗi không xác định.';
    }
  }
}

class JobDetailService {
  final ApiClient _client = ApiClient();
  static const String _basePath =
      '/api/cong-viec/lay-cong-viec-chi-tiet';

  Future<dynamic> fetchJobDetailById(int maCongViec) async {
    try {
      final response = await _client.get('$_basePath/$maCongViec');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic>? content =
            responseData['content'] as List<dynamic>?;

        if (content != null && content.isNotEmpty) {
          return CongViecItem.fromJson(
              content.first as Map<String, dynamic>);
        }
        return 'Không tìm thấy công việc.';
      }

      return 'Lấy chi tiết thất bại.';
    } on DioException catch (_) {
      return 'Lỗi kết nối mạng.';
    } catch (_) {
      return 'Lỗi không xác định.';
    }
  }
}

class PostComment {
  final ApiClient _client = ApiClient();

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    if (token == null) return null;

    try {
      final jwt = JWT.decode(token);
      return int.tryParse(jwt.payload['id'].toString());
    } catch (e) {
      if (kDebugMode) {
        print('JWT decode error: $e');
      }
      return null;
    }
  }

  Future<bool> sendComment({
    required int jobId,
    required String content,
    required int rating,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    final userId = await _getUserId();

    if (userId == null || token == null) return false;

    try {
      final response = await _client.post(
        '/api/binh-luan',
        data: {
          'id': 0,
          'maCongViec': jobId,
          'maNguoiBinhLuan': userId,
          'ngayBinhLuan': DateTime.now().toIso8601String(),
          'noiDung': content,
          'saoBinhLuan': rating,
        },
        options: Options(headers: {'token': token}),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
