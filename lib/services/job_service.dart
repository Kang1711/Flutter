import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../objects/works.dart';

class JobService {
  final ApiClient _client = ApiClient();
  static const String _basePath = '/api/cong-viec/lay-danh-sach-cong-viec-theo-ten';

  Future<dynamic> searchJobsByName(String jobName) async {
    final encodedJobName = Uri.encodeComponent(jobName);
    final String path = '$_basePath/$encodedJobName';

    print('[GET] Tìm kiếm công việc: $path');

    try {
      final response = await _client.get(path);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;

        final List<dynamic>? jobListRaw = responseData['content'] as List<dynamic>?;
        
        if (jobListRaw != null) {

          return jobListRaw.cast<Map<String, dynamic>>();
        }
        return 'Không tìm thấy danh sách công việc.';
      }

      final errorMessage = response.data['message'] ?? 'Tìm kiếm thất bại. Mã: ${response.statusCode}';
      print('Lỗi API khi tìm kiếm: $errorMessage');
      return errorMessage;

    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data['message'] ?? e.message;
      
      if (statusCode == 404) {
        return 'Không tìm thấy công việc phù hợp.';
      }
      if (statusCode == 401) {
        return 'Lỗi xác thực: Token không hợp lệ.';
      }

      print('Lỗi Dio khi tìm kiếm: $errorMessage');
      return errorMessage ?? 'Lỗi kết nối mạng.';
    } catch (e) {
      print('Lỗi không xác định khi tìm kiếm công việc: $e');
      return 'Lỗi không xác định.';
    }
  }
}

class JobCategoryService {
  final ApiClient _client = ApiClient();
  static const String _menuPath = '/api/cong-viec/lay-menu-loai-cong-viec';

  Future<dynamic> fetchJobMenu() async {
    print('[GET] Lấy menu loại công việc: $_menuPath');

    try {
      final response = await _client.get(_menuPath);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic>? content =
            responseData['content'] as List<dynamic>?;

        if (content != null) {
          return content
              .map(
                (item) => LoaiCongViec.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return 'Phản hồi không chứa dữ liệu menu hợp lệ.';
      }

      final errorMessage =
          response.data['message'] ??
          'Lấy menu thất bại. Mã: ${response.statusCode}';
      print('Lỗi API khi lấy menu: $errorMessage');
      return errorMessage;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data['message'] ?? e.message;
      print('Lỗi Dio khi lấy menu: $errorMessage (Status: $statusCode)');
      return errorMessage ?? 'Lỗi kết nối mạng';
    } catch (e) {
      print('Lỗi không xác định khi lấy menu công việc: $e');
      return 'Lỗi không xác định.';
    }
  }
}

class AuthService {
  final ApiClient _client = ApiClient();
  static const String _loginPath = '/api/auth/signin';

  Future<dynamic> signIn(String email, String password) async {
    final Map<String, dynamic> data = {'email': email, 'password': password};

    try {
      print('[POST] Gửi yêu cầu Đăng nhập: $data');
      final response = await _client.post(_loginPath, data: data);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
      
      return "Đăng nhập thất bại. Phản hồi không hợp lệ.";

    } on DioException catch (e) {
      
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        return e.response?.data?['message'] ??
            "Email hoặc mật khẩu không đúng.";
      }
      
      return "Lỗi kết nối mạng: Vui lòng thử lại.";

    } catch (e) {
      return "Lỗi không xác định.";
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
      } else {
        throw Exception("Đăng ký thất bại.");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 409 ||
          e.response?.statusCode == 401) {
        return e.response?.data['message'] ??
            "Lỗi đăng ký: Dữ liệu không hợp lệ.";
      }
      return "Lỗi kết nối mạng: Vui lòng thử lại.";
    } catch (e) {
      return "Lỗi không xác định: $e";
    }
  }
}
class CommentService {
  final ApiClient _client = ApiClient();
  static const String _basePath =
      '/api/binh-luan/lay-binh-luan-theo-cong-viec';

  Future<dynamic> fetchCommentsByJobId(int maCongViec) async {
    final String path = '$_basePath/$maCongViec';

    print('[GET] Lấy bình luận theo công việc: $path');

    try {
      final response = await _client.get(path);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic>? content =
            responseData['content'] as List<dynamic>?;

        if (content != null) {
          return BinhLuan.fromJsonList(content);
        }

        return 'Không có bình luận nào.';
      }

      final errorMessage =
          response.data['message'] ??
          'Lấy bình luận thất bại. Mã: ${response.statusCode}';
      print('Lỗi API khi lấy bình luận: $errorMessage');
      return errorMessage;

    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data['message'] ?? e.message;

      if (statusCode == 404) {
        return 'Không tìm thấy bình luận cho công việc này.';
      }
      if (statusCode == 401) {
        return 'Lỗi xác thực: Token không hợp lệ.';
      }

      print('Lỗi Dio khi lấy bình luận: $errorMessage');
      return errorMessage ?? 'Lỗi kết nối mạng.';
    } catch (e) {
      print('Lỗi không xác định khi lấy bình luận: $e');
      return 'Lỗi không xác định.';
    }
  }
}

class JobDetailService {
  final ApiClient _client = ApiClient();
  static const String _basePath = '/api/cong-viec/lay-cong-viec-chi-tiet';

  Future<dynamic> fetchJobDetailById(int maCongViec) async {
    final String path = '$_basePath/$maCongViec';

    print('[GET] Lấy công việc chi tiết: $path');

    try {
      final response = await _client.get(path);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic>? content = responseData['content'] as List<dynamic>?;

        if (content != null && content.isNotEmpty) {
          return CongViecItem.fromJson(
            content[0] as Map<String, dynamic>,
          );
        }
        return 'Không tìm thấy thông tin chi tiết cho công việc này.';
      }

      return response.data['message'] ?? 'Lấy chi tiết công việc thất bại.';
      
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data['message'] ?? e.message;

      if (statusCode == 404) return 'Không tìm thấy công việc.';
      if (statusCode == 401) return 'Lỗi xác thực.';

      return errorMessage ?? 'Lỗi kết nối mạng.';
    } catch (e) {
      print('Lỗi không xác định khi lấy chi tiết: $e');
      return 'Lỗi không xác định.';
    }
  }
}