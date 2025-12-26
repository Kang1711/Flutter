import 'package:cyber/objects/works.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentItem extends StatelessWidget {
  final BinhLuan binhLuan;

  const CommentItem({required this.binhLuan, super.key});

  @override
  Widget build(BuildContext context) {
    final displayName = binhLuan.tenNguoiBinhLuan.isNotEmpty
        ? binhLuan.tenNguoiBinhLuan
        : 'Anonymous';
    final avatarWidget = binhLuan.avatar.isNotEmpty
        ? CircleAvatar(backgroundImage: NetworkImage(binhLuan.avatar))
        : CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Text(
              displayName[0].toUpperCase(),
              style: TextStyle(color: Colors.white),
            ),
          );
    final flag = '🇺🇸';
    final ngay = DateFormat('dd/MM/yyyy HH:mm').format(binhLuan.ngayBinhLuan);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: avatarWidget,
            title: Text(displayName),
            subtitle: Text(flag),
          ),
          SizedBox(height: 4),
          Text(binhLuan.noiDung, maxLines: 3, overflow: TextOverflow.ellipsis),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.black),
                  const SizedBox(width: 4),
                  Text(binhLuan.saoBinhLuan.toString()),
                ],
              ),
              Text(ngay, style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}