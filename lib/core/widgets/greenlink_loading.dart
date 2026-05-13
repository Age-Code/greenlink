import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GreenlinkLoading extends StatelessWidget {
  final String? message;
  const GreenlinkLoading({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primaryStrong,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.bodyMuted,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
