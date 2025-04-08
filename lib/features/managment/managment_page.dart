import 'package:apiarium/features/managment/managment_view.dart';
import 'package:flutter/material.dart';

class ManagmentPage extends StatelessWidget {
  const ManagmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const ManagmentView(),
    );
  }
}