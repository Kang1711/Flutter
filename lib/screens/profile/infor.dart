import 'package:cyber/screens/profile/widgets/edit.dart';
import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../../bar.dart'; 

class UserService {
  final ApiClient _client = ApiClient();
  static const String _userPath = '/api/users';

  Future<int?> getUserIdFromToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('user_token');

    if (token == null) {
      print('Token không tồn tại trong SharedPreferences.');
      return null;
    }
    Map<String, dynamic>? userData;
    try {
      final JWT jwt = JWT.decode(token);
      userData = jwt.payload as Map<String, dynamic>;
    } on JWTException {
      print('Lỗi giải mã: Cấu trúc JWT sai.');
      return null;
    } catch (e) {
      print('Lỗi giải mã token: $e');
      return null;
    }
    dynamic userIdRaw = userData['id'];
    if (userIdRaw != null) {
      if (userIdRaw is int) {
        return userIdRaw;
      } else if (userIdRaw is String) {
        return int.tryParse(userIdRaw);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    final int? userId = await getUserIdFromToken();
    if (userId == null) {
      print('Lỗi: Không tìm thấy User ID đã lưu. Không thể gọi API.');
      return null;
    }

    final String path = '$_userPath/$userId';
    try {
      final response = await _client.get(path);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['content'] as Map<String, dynamic>?;
      }
      print('Lỗi: Phản hồi API không thành công (${response.statusCode}).');
      return null;
    } on DioException catch (e) {
      print('Lỗi Dio khi lấy thông tin người dùng: ${e.response?.statusCode ?? 'N/A'} - ${e.message}');
      return null;
    } catch (e) {
      print('Lỗi không xác định khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  Future<dynamic> patchUserProfile(
    int userId,
    Map<String, dynamic> data,
  ) async {
    final String path = '$_userPath/$userId';
    print('[PUT/PATCH] Cập nhật thông tin người dùng: $path');
    print('Payload gửi đi: ${data.toString()}'); 
    try {
      final response = await _client.put(path, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Cập nhật hồ sơ thành công.');
        return true;
      }
      final errorMessage =
          response.data['message'] ??
          'Cập nhật thất bại. Mã: ${response.statusCode}';
      print('Lỗi API khi cập nhật hồ sơ: $errorMessage');
      return errorMessage;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final serverMessage = e.response?.data is Map ? e.response?.data['message'] : null;
      
      String errorMessage = 'Lỗi kết nối mạng hoặc server.';
      
      if (statusCode != null) {
          errorMessage = 'Lỗi $statusCode: ${serverMessage ?? e.message}';
      } else {
          errorMessage = e.message ?? 'Lỗi kết nối mạng.';
      }

      print('Lỗi Dio khi cập nhật hồ sơ: $errorMessage');
      return errorMessage;
    } catch (e) {
      print('Lỗi không xác định khi cập nhật hồ sơ: $e');
      return 'Lỗi không xác định.';
    }
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final data = await _userService.getUserDetails();

    setState(() {
      _isLoading = false;
      if (data != null) {
        _userData = data;
      } else {
        _errorMessage = "Không thể tải hồ sơ. Vui lòng kiểm tra lại đăng nhập.";
      }
    });
  }

  void _openEditModal(String section, Map<String, dynamic> currentData) {
    final int? userId = currentData['id'] as int?;
    if (userId == null) {
      setState(
        () => _errorMessage = 'Lỗi: Không tìm thấy ID người dùng để cập nhật.',
      );
      return;
    }

    void handleApiResult(dynamic result) {
      if (result == true) {
        Navigator.pop(context);
        _loadProfileData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công! Đang tải lại dữ liệu...'),
          ),
        );
      } else {
        final errorMessage = result is String
            ? result
            : 'Cập nhật thất bại không xác định.';
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thất bại: $errorMessage')),
        );
      }
    }

    if (section == 'Description') {
      showDialog(
        context: context,
        builder: (context) => EditDescriptionModal(
          initialData: currentData,
          onSave: (Map<String, dynamic> newData) async {
            final fullPayload = Map<String, dynamic>.from(currentData);
            fullPayload['id'] = userId; 
            fullPayload.addAll(newData);
            fullPayload['skill'] = fullPayload['skill'] is List ? fullPayload['skill'] : [];
            fullPayload['certification'] = fullPayload['certification'] is List ? fullPayload['certification'] : [];

            final result = await _userService.patchUserProfile(
              userId,
              fullPayload,
            );
            handleApiResult(result);
          },
        ),
      );
    }
    else if (section == 'Skills' || section == 'Certifications') {
      final String dataKey = section.toLowerCase() == 'skills' ? 'skill' : 'certification';
      final dynamic rawList = currentData[dataKey];
      final List<String> currentList = rawList is List
          ? List<String>.from(rawList)
          : [];
      showDialog(
        context: context,
        builder: (context) => EditListModal(
          title: section,
          initialList: currentList,
          onSave: (List<String> newList) async {
            final fullPayload = Map<String, dynamic>.from(currentData);
            fullPayload['id'] = userId; 
            fullPayload[dataKey] = newList;
            final String otherKey = dataKey == 'skill' ? 'certification' : 'skill';
            fullPayload[otherKey] = fullPayload[otherKey] is List ? fullPayload[otherKey] : [];

            final result = await _userService.patchUserProfile(
              userId,
              fullPayload,
            );
            handleApiResult(result);
          },
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: const SafeArea(child: CustomBottomBar()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
        ),
      );
    }

    final data = _userData ?? {};

    final String name = data['name'] ?? 'Chưa cập nhật';
    final String phone = data['phone'] ?? 'N/A';
    final String birthday = data['birthday'] ?? 'N/A';
    const String memberSince = 'Oct 2022';
    final String email = data['email'] ?? 'N/A';
    final String gender = data['gender'] == true
        ? 'Nam'
        : (data['gender'] == false ? 'Nữ' : 'N/A');
    final String role = data['role'] ?? 'N/A';
    final dynamic rawSkills = data['skill'];
    final List<String> skills = rawSkills is List
        ? List<String>.from(rawSkills)
        : [];

    final dynamic rawCertifications = data['certification'];
    final List<String> certifications = rawCertifications is List
        ? List<String>.from(rawCertifications)
        : [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(name, memberSince),
          Container(height: 3.0, color: Colors.green[700]),

          _buildSectionHeader('Description'),
          _buildDetailRows(name, phone, birthday, email, gender, role),

          _buildSectionHeader('Skills'),
          _buildListContent(skills, 'skills'),

          _buildSectionHeader('Certifications'),
          _buildListContent(certifications, 'certifications'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      color: Colors.grey[200],
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildEditButton(title),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String name, String memberSince) {
    return Container(
      color: Colors.green[700],
      child: SafeArea(
        bottom: false,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          leading: const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.grey),
          ),
          title: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'member since $memberSince',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              print('Đã nhấn nút Thông báo');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRows(
    String name,
    String phone,
    String birthday,
    String email,
    String gender,
    String role,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Name', name),
          _buildDetailRow('Email', email),
          _buildDetailRow('Phone', phone),
          _buildDetailRow('Birthday', birthday),
          _buildDetailRow('Gender', gender),
          _buildDetailRow('Role', role),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildListContent(List<String> items, String sectionName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          if (items.isEmpty)
            Text(
              'Chưa có $sectionName nào được thêm.',
              style: TextStyle(color: Colors.grey[600]),
            )
          else
            ...items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text('• $item'),
                  ),
                )
                .toList(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildEditButton(String sectionName) {
    return TextButton(
      onPressed: () {
        _openEditModal(sectionName, _userData ?? {});
      },
      child: Text('edit', style: TextStyle(color: Colors.green[700])),
    );
  }
}