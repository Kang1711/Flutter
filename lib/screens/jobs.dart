import 'package:flutter/material.dart';
import '../services/job_service.dart';
import '../bar.dart';
import '../objects/works.dart';

class ListJob extends StatefulWidget {
  const ListJob({super.key});

  @override
  State<ListJob> createState() => _ListJobState();
}

class _ListJobState extends State<ListJob> {
  final JobCategoryService _service = JobCategoryService();
  final JobService _jobService = JobService();
  List<LoaiCongViec> _jobMenu = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _query = 'Design';
  List<Map<String, dynamic>> _jobs = [];
  bool _isInitialDataLoaded = false;
  @override
  void initState() {
    super.initState();
    _loadJobMenu();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialDataLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      _query = (args is String && args.trim().isNotEmpty) ? args : 'Design';
      _loadJobsByQuery();
      _isInitialDataLoaded = true;
    }
  }

  Future<void> _loadJobMenu() async {
    setState(() {
      _errorMessage = null;
    });
    final result = await _service.fetchJobMenu();

    setState(() {
      if (result is List<LoaiCongViec>) {
        _jobMenu = result;
      } else {
        _errorMessage = result;
      }
    });
  }

  Future<void> _loadJobsByQuery() async {
    setState(() {
      _isLoading = true;
    });
    final result = await _jobService.searchJobsByName(_query);
    setState(() {
      _isLoading = false;
      if (result is List<Map<String, dynamic>>) {
        _jobs = result;
      } else {
        _errorMessage = result.toString();
        _jobs = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SafeArea(child: CustomBottomBar()),

      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        title: Text(
          _query,
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 28),
            onPressed: () {
              print('Đã nhấn nút Search');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          'Lỗi tải dữ liệu: $_errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_jobMenu.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy danh mục công việc nào.'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHorizontalCategoryBar(),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            "Shop by '$_query'",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 18),

        Expanded(
          child: _jobs.isEmpty
              ? Center(
                  child: Text("Không tìm thấy công việc nào cho '$_query'."),
                )
              : ListView.builder(
                  itemCount: _jobs.length,
                  itemBuilder: (context, index) {
                    final congViec = _jobs[index];
                    final jobData =
                        congViec["congViec"] as Map<String, dynamic>? ?? {};
                    final String hinhAnh = jobData["hinhAnh"] as String? ?? '';
                    final String saoCongViec =
                        jobData["saoCongViec"]?.toString() ?? '0';
                    final String danhGia =
                        jobData["danhGia"]?.toString() ?? '0';
                    final String tenCongViec =
                        jobData["tenCongViec"]?.toString() ??
                        'Dịch vụ không tên';
                    final String giaTien =
                        jobData["giaTien"]?.toString() ?? 'NULL';
                    final int id = jobData["id"] as int;
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/detail',
                          arguments: id,
                        );
                      },
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          height: 120,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Flexible(
                                flex: 4,
                                child: Container(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  child: Image.network(
                                    hinhAnh,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 7,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 16.0,
                                              ),
                                              const SizedBox(width: 4.0),
                                              Text(
                                                saoCongViec,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "($danhGia)",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Icon(
                                            Icons.favorite_border,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        tenCongViec,
                                        style: const TextStyle(fontSize: 15),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: 'From ',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '\$$giaTien',
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                    255,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHorizontalCategoryBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _jobMenu.length,
        itemBuilder: (context, index) {
          final category = _jobMenu[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 16.0 : 8.0),
            child: GestureDetector(
              onTap: () {
                Map<String, dynamic> dataToSend = {
                  'id': category.id,
                  'tenLoaiCongViec': category.tenLoaiCongViec,
                  'dsNhomChiTietLoai': category.dsNhomChiTietLoai
                      .map(
                        (n) => {
                          'id': n.id,
                          'tenNhom': n.tenNhom,
                          'hinhAnh': n.hinhAnh,
                          'dsChiTietLoai': n.dsChiTietLoai
                              .map(
                                (c) => {'id': c.id, 'tenChiTiet': c.tenChiTiet},
                              )
                              .toList(),
                        },
                      )
                      .toList(),
                };
                Navigator.pushNamed(context, '/list', arguments: dataToSend);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                child: Center(child: Text(category.tenLoaiCongViec)),
              ),
            ),
          );
        },
      ),
    );
  }
}
