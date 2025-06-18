import 'package:flutter/material.dart';
import 'face_blur_screen_a.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FaceBlurScreenA()),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(24),
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text(
            'A',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
