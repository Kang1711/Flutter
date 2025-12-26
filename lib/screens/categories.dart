import '../objects/works.dart';
import 'package:flutter/material.dart';
import '../bar.dart';
import '../services/job_service.dart';

class JobCategoryScreen extends StatefulWidget {
  const JobCategoryScreen({super.key});

  @override
  State<JobCategoryScreen> createState() => _JobCategoryScreenState();
}

class _JobCategoryScreenState extends State<JobCategoryScreen>
    with SingleTickerProviderStateMixin {
  final JobCategoryService _service = JobCategoryService();
  List<LoaiCongViec> _jobMenu = [];
  bool _isLoading = true;
  String? _errorMessage;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadJobMenu();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadJobMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _service.fetchJobMenu();

    setState(() {
      _isLoading = false;
      if (result is List<LoaiCongViec>) {
        _jobMenu = result;
      } else if (result is String) {
        _errorMessage = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SafeArea(child: CustomBottomBar()),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Categories'),
                Tab(text: 'Interests'),
              ],
              indicatorColor: Colors.green,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(),
          const Center(child: Text("Interests UI sẽ được xây dựng sau.")),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          'Lỗi: $_errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_jobMenu.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy danh mục công việc nào.'),
      );
    }

    return ListView.separated(
      itemCount: _jobMenu.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey.shade200, indent: 16),
      itemBuilder: (context, index) {
        final loaiCongViec = _jobMenu[index];

        final subtitleText = loaiCongViec.dsNhomChiTietLoai
            .map((nhom) => nhom.tenNhom)
            .take(3)
            .join(', ');

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),

          leading: Image.asset(
            'assets/image/${loaiCongViec.id}.png',
            width: 48,
            height: 48,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.work_outline,
                size: 48,
                color: Colors.grey,
              );
            },
          ),
          title: Text(
            loaiCongViec.tenLoaiCongViec,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitleText,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Map<String, dynamic> dataToSend = {
              'id': loaiCongViec.id,
              'tenLoaiCongViec': loaiCongViec.tenLoaiCongViec,
              'dsNhomChiTietLoai': loaiCongViec.dsNhomChiTietLoai
                  .map(
                    (n) => {
                      'id': n.id,
                      'tenNhom': n.tenNhom,
                      'hinhAnh': n.hinhAnh,
                      'dsChiTietLoai': n.dsChiTietLoai
                          .map((c) => {'id': c.id, 'tenChiTiet': c.tenChiTiet})
                          .toList(),
                    },
                  )
                  .toList(),
            };
            Navigator.pushNamed(context, '/list', arguments: dataToSend);
          },
        );
      },
    );
  }
}
