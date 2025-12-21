import 'package:flutter/material.dart';

class ItemModel {
  final String name;
  final String imageUrl;

  ItemModel({required this.name, required this.imageUrl});
}

final List<ItemModel> items = [
  ItemModel(
    name: "Logo Design",
    imageUrl:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTgNDaAYOmghNKrXZTT9YKiKG5eXL2zGGWSNg&s",
  ),
  ItemModel(
    name: "AI Artists",
    imageUrl:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ6VqIHvgsQXwv_fZLsHOcv8c0MjyLQTSwhSA&s",
  ),
  ItemModel(
    name: "Logo Artists",
    imageUrl:
        "https://blog.artweb.com/wp-content/uploads/2023/02/Artist-Logo-Examples-2.png",
  ),
  ItemModel(
    name: "Data",
    imageUrl:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRc9aLHUnEMHtGPEB9UDHQWsSGhvaGWdxbaMw&s",
  ),
  ItemModel(
    name: "Business",
    imageUrl:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcScDonUVPsLU8-evdzwold7t1FlWwz3dapYCw&s",
  ),
];

class CardItem extends StatelessWidget {
  final ItemModel item;

  const CardItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.network(item.imageUrl, height: 110, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.name,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
