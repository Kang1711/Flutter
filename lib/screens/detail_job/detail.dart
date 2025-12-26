import 'package:flutter/material.dart';
import '../../services/job_service.dart';
import '../../bar.dart';
import '../../objects/works.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'widgets/price_detail_card.dart';
import 'widgets/level_badge.dart';
import 'widgets/comment_item.dart';
import 'widgets/reviews_summary.dart';

class DetailJob extends StatefulWidget {
  const DetailJob({super.key});

  @override
  State<DetailJob> createState() => _DetailJobState();
}

class _DetailJobState extends State<DetailJob> {
  final JobDetailService _jobDetailService = JobDetailService();
  final CommentService _commentService = CommentService();
  final PostComment _postService = PostComment();

  CongViecItem? _jobDetail;
  List<BinhLuan> _comments = [];

  bool _isLoading = true;
  String? _errorMessage;
  int _jobId = 0;
  bool _isInitialDataLoaded = false;
  double _mean = 0.0;

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
          _mean = _comments.isEmpty
              ? 0.0
              : _comments.map((m) => m.saoBinhLuan).reduce((a, b) => a + b) /
                    _comments.length;
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
            SliverToBoxAdapter(
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
            const SliverToBoxAdapter(
              child: Divider(thickness: 1, color: Colors.grey),
            ),
            SliverToBoxAdapter(child: Container(height: 10)),
            const SliverToBoxAdapter(
              child: Divider(thickness: 1, color: Colors.grey),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SimpleRating(rating: _mean),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ReviewsSummary(
                  mean: _mean,
                  numReviews: _comments.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _comments.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          "Chưa có bình luận nào",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _comments.length > 4 ? 4 : _comments.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 12.0,
                              right: 8,
                            ),
                            child: SizedBox(
                              width: 250,
                              child: CommentItem(binhLuan: _comments[index]),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StaticCommentForm(
                  onSend: (content, rating) async {
                    final success = await _postService.sendComment(
                      jobId: _jobId,
                      content: content,
                      rating: rating,
                    );
                    if (success) {
                      _loadAllData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Đã đăng bình luận!")),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleRating extends StatelessWidget {
  final double rating;

  const SimpleRating({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) =>
              const Icon(Icons.star, color: Colors.black),
          unratedColor: Colors.grey.shade300,
          itemCount: 5,
          itemSize: 26.0,
          direction: Axis.horizontal,
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ],
    );
  }
}

class StaticCommentForm extends StatefulWidget {
  final Function(String content, int rating) onSend;

  const StaticCommentForm({super.key, required this.onSend});

  @override
  State<StaticCommentForm> createState() => _StaticCommentFormState();
}

class _StaticCommentFormState extends State<StaticCommentForm> {
  final _controller = TextEditingController();
  double _currentRating = 5.0;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add your comment",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          RatingBar.builder(
            initialRating: 5,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 30,
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) => setState(() => _currentRating = rating),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter your review...",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DBF73),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  widget.onSend(_controller.text, _currentRating.toInt());
                  _controller.clear();
                }
              },
              child: const Text(
                "Send",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
