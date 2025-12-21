import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBarItem(Icons.home_outlined, '/home', currentRoute, context),
          _buildBarItem(Icons.mail_outline, '/mail', currentRoute, context),
          _buildBarItem(Icons.search, '/search', currentRoute, context),
          _buildBarItem(Icons.assignment_outlined, '/notes', currentRoute, context),
          _buildBarItem(Icons.person_outline, '/profile', currentRoute, context),
        ],
      ),
    );
  }

  Widget _buildBarItem(
    IconData icon,
    String routeName,
    String? currentRoute,
    BuildContext context,
  ) {
    final isActive = currentRoute == routeName;

    return IconButton(
      onPressed: () {
        if (!isActive) Navigator.pushReplacementNamed(context, routeName);
      },
      icon: isActive
          ? Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Icon(icon, color: Colors.green, size: 24),
            )
          : Icon(icon, color: Colors.black),
    );
  }
}