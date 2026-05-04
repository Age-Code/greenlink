import 'package:flutter/material.dart';

class GreenlinkLoading extends StatelessWidget {
  const GreenlinkLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
