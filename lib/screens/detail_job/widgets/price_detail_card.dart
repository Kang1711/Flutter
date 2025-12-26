import 'package:flutter/material.dart';

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