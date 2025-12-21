import 'package:flutter/material.dart';
import 'package:cyber/bar.dart';

class JobListPage extends StatefulWidget {
  const JobListPage({super.key});

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  late String _categoryName;
  late List<dynamic> _detailGroups;
  bool _isDataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      final Map<String, dynamic>? arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        _categoryName = arguments['tenLoaiCongViec'] ?? 'Chi Tiết Công Việc';
        _detailGroups = arguments['dsNhomChiTietLoai'] ?? [];
        _isDataLoaded = true;
      } else {
        _categoryName = 'Lỗi Tải Dữ Liệu';
        _detailGroups = [];
      }
    }
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    final String groupName = group['tenNhom'] ?? 'Nhóm không tên';
    final String imageUrl =
        group['hinhAnh'] ??
        'https://yt3.googleusercontent.com/48ju2YdLey_B-U__0pNPNMrmwLXyesqMc-sc_d1EYtXNThlepx31sbhQNWqRDqCQ9ZfeclZT0Q=s176-c-k-c0x00ffffff-no-rj-mo';
    final List<dynamic> detailItems = group['dsChiTietLoai'] ?? [];
    final String detailSummary = detailItems
        .map((item) => item['tenChiTiet'] as String)
        .take(2)
        .join(', ');
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Đã chọn nhóm: $groupName')));
          // TODO: Thêm logic điều hướng tới danh sách công việc của nhóm này
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.green,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    groupName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detailSummary.isNotEmpty
                        ? detailSummary
                        : 'Không có chi tiết.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDataLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      bottomNavigationBar: const SafeArea(child: CustomBottomBar()),
      appBar: AppBar(
        title: Text(_categoryName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      body: _detailGroups.isEmpty
          ? const Center(child: Text('Không có nhóm chi tiết nào.'))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _detailGroups.length,
                itemBuilder: (context, index) {
                  return _buildGroupCard(
                    _detailGroups[index] as Map<String, dynamic>,
                  );
                },
              ),
            ),
    );
  }
}
