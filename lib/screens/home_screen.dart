import 'package:flutter/material.dart';
import 'face_blur_screen_a.dart';
import 'face_blur_screen_b.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FaceBlurScreenA(),
                  ),
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
            const SizedBox(width: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const FaceBlurScreenB()),
            //     );
            //   },
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.all(24),
            //     shape: const CircleBorder(),
            //     backgroundColor: Theme.of(context).colorScheme.primary,
            //   ),
            //   child: const Text(
            //     'B',
            //     style: TextStyle(
            //       fontSize: 32,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.white,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
