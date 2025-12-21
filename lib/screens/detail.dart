import 'package:flutter/material.dart';
import '../services/job_service.dart';
import '../bar.dart';
import '../objects/works.dart';
import 'package:readmore/readmore.dart';

class DetailJob extends StatefulWidget {
  const DetailJob({super.key});

  @override
  State<DetailJob> createState() => _DetailJobState();
}

class _DetailJobState extends State<DetailJob> {
  final JobDetailService _jobDetailService = JobDetailService();
  final CommentService _commentService = CommentService();

  CongViecItem? _jobDetail;
  List<BinhLuan> _comments = [];

  bool _isLoading = true;
  String? _errorMessage;
  int _jobId = 0;
  bool _isInitialDataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialDataLoaded) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _jobId = args;
    } else if (args is String) {
      _jobId = int.tryParse(args) ?? 0;
    }

    if (_jobId == 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Mã công việc không hợp lệ';
      });
    } else {
      _loadAllData();
    }

    _isInitialDataLoaded = true;
  }

  Future<void> _loadAllData() async {
    try {
      final results = await Future.wait([
        _jobDetailService.fetchJobDetailById(_jobId),
        _commentService.fetchCommentsByJobId(_jobId),
      ]);

      if (!mounted) return;

      setState(() {
        _isLoading = false;

        if (results[0] is CongViecItem) {
          _jobDetail = results[0] as CongViecItem;
        } else {
          _errorMessage = results[0].toString();
        }

        if (results[1] is List<BinhLuan>) {
          _comments = results[1] as List<BinhLuan>;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi tải dữ liệu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null || _jobDetail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_errorMessage ?? 'Lỗi dữ liệu')),
      );
    }

    final detail = _jobDetail!.congViec;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        bottomNavigationBar: const SafeArea(child: CustomBottomBar()),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 300,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  detail.hinhAnh,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color.fromARGB(255, 237, 102, 102),
                    child: const Icon(Icons.broken_image, size: 60),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,

                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _jobDetail!.avatar.isNotEmpty
                          ? _jobDetail!.avatar
                          : 'https://www.creativefabrica.com/wp-content/uploads/2023/05/20/User-icon-Graphics-70077892-1.jpg',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    _jobDetail!.tenNguoiTao.isNotEmpty
                        ? _jobDetail!.tenNguoiTao
                        : 'Anonymous',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Align(
                    alignment: Alignment.centerLeft,
                    child: LevelBadge(level: detail.saoCongViec),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_down,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  top: 22,
                  right: 16,
                  bottom: 0,
                ),
                child: SelectableText(
                  detail.tenCongViec,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ReadMoreText(
                  detail.moTa,
                  trimLines: 2,
                  colorClickableText: Colors.green,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: ' More',
                  trimExpandedText: ' Less',
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  moreStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Divider(thickness: 1, color: Colors.grey),
            ),
            SliverToBoxAdapter(child: Container(height: 10)),
            const SliverToBoxAdapter(
              child: Divider(thickness: 1, color: Colors.grey),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: const TabBar(
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.green,
                  tabs: [
                    Tab(text: "\$60"),
                    Tab(text: "\$40"),
                    Tab(text: "\$20"),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox(
                height: 500,
                child: TabBarView(
                  children: [
                    BuildPriceDetail(
                      price: 60,
                      title: "Premium",
                      description: detail.moTaNgan,
                    ),
                    BuildPriceDetail(
                      price: 40,
                      title: "Standard",
                      description: detail.moTaNgan,
                    ),
                    BuildPriceDetail(
                      price: 20,
                      title: "Basic",
                      description: detail.moTaNgan,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LevelBadge extends StatelessWidget {
  final int level;

  const LevelBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Level $level',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          _diamond(true),
          _diamond(level >= 2),
          _diamond(level >= 3),
        ],
      ),
    );
  }

  Widget _diamond(bool active) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Transform.rotate(
        angle: 0.785398,
        child: Icon(
          Icons.square,
          size: 10,
          color: active ? Colors.black : Colors.black26,
        ),
      ),
    );
  }
}

class BuildPriceDetail extends StatefulWidget {
  final int price;
  final String title;
  final String description;

  const BuildPriceDetail({
    super.key,
    required this.price,
    required this.title,
    required this.description,
  });

  @override
  State<BuildPriceDetail> createState() => _BuildPriceDetailState();
}

class _BuildPriceDetailState extends State<BuildPriceDetail> {
  bool expressSelected = false;
  int get totalPrice => widget.price + (expressSelected ? 20 : 0);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            widget.description,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),

          _buildInfoRow("Revisions", "Unlimited"),
          _buildInfoRow("Delivery Days", "3 Days"),
          _buildInfoRow("Number of concepts included", "1"),

          const SizedBox(height: 10),

          _buildCheckRow("Logo transparency", true),
          _buildCheckRow("Vector file", false),
          _buildCheckRow("Printable file", false),
          _buildCheckRow("3D mockup", true),
          _buildCheckRow("Source file", false),

          const SizedBox(height: 20),
          _buildExpressDeliveryRow(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DBF73),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                "Continue (\$$totalPrice)",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 24,
                color: Color.fromARGB(255, 119, 118, 118),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 18),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String label, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 18),
          ),
          isAvailable
              ? const Icon(Icons.check, color: Color(0xFF1DBF73), size: 18)
              : const Text(
                  "__",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildExpressDeliveryRow() {
    return InkWell(
      onTap: () => setState(() => expressSelected = !expressSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2),
                    color: expressSelected ? Colors.green : Colors.transparent,
                  ),
                  child: expressSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Express Delivery in 24 Hours",
                  style: TextStyle(color: Colors.black87, fontSize: 18),
                ),
              ],
            ),
            Text(
              "+\$20",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
