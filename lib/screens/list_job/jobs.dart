import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:cyber/bar.dart';
import 'package:cyber/objects/works.dart';
import 'package:cyber/screens/list_job/widgets/category_horizontal_list.dart';
import 'package:cyber/screens/list_job/widgets/job_card.dart';
import 'package:cyber/services/job_service.dart';
import 'package:flutter/material.dart';

class ListJobScreen extends StatefulWidget {
  const ListJobScreen({super.key});

  @override
  State<ListJobScreen> createState() => _ListJobScreenState();
}

class _ListJobScreenState extends State<ListJobScreen> {
  final JobCategoryService _categoryService = JobCategoryService();
  final JobService _jobService = JobService();

  final TextEditingController _searchController = TextEditingController();

  List<LoaiCongViec> _categories = [];
  List<Map<String, dynamic>> _jobs = [];

  bool _isLoading = true;
  bool _isInitialized = false;
  String _query = 'Design';
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.trim().isNotEmpty) {
        _query = args;
      }
      _loadJobs();
      _isInitialized = true;
    }
  }

  Future<void> _loadCategories() async {
    final result = await _categoryService.fetchJobMenu();
    setState(() {
      if (result is List<LoaiCongViec>) {
        _categories = result;
      } else {
        _errorMessage = result.toString();
      }
    });
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    final result = await _jobService.searchJobsByName(_query);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result is List<Map<String, dynamic>>) {
        _jobs = result;
      } else {
        _jobs = [];
        _errorMessage = result.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SafeArea(child: CustomBottomBar()),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Text(
        _query,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: AnimSearchBar(
            width: MediaQuery.of(context).size.width * 0.8,
            textController: _searchController,
            onSuffixTap: () => _searchController.clear(),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                setState(() => _query = value);
                _loadJobs();
              }
            },
            color: Colors.white,
            helpText: "Search by '$_query'...",
            closeSearchOnSuffixTap: true,
            autoFocus: true,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryHorizontalList(categories: _categories),
        const SizedBox(height: 12),
        Expanded(
          child: _jobs.isEmpty
              ? Center(
                  child: Text("Không tìm thấy công việc nào cho '$_query'."),
                )
              : ListView.builder(
                  itemCount: _jobs.length,
                  itemBuilder: (context, index) {
                    return JobCard(
                      job: _jobs[index],
                      onTap: () {
                        final id = _jobs[index]['congViec']['id'];
                        Navigator.pushNamed(context, '/detail', arguments: id);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
