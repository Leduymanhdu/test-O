import 'package:flutter/material.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: const Center(
        child: EmptyState(
          icon: Icons.home,
          message: 'Màn hình trang chủ\n(Sẽ được triển khai)',
        ),
      ),
    );
  }
}
