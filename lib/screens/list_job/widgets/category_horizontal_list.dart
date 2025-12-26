import 'package:cyber/objects/works.dart';
import 'package:flutter/material.dart';

class CategoryHorizontalList extends StatelessWidget {
  final List<LoaiCongViec> categories;

  const CategoryHorizontalList({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 16 : 8),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/list', arguments: category.toMap());
              },
              child: Chip(label: Text(category.tenLoaiCongViec)),
            ),
          );
        },
      ),
    );
  }
}
