import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/face_blur_service.dart';

class FaceBlurScreen extends StatefulWidget {
  const FaceBlurScreen({super.key});

  @override
  FaceBlurScreenState createState() => FaceBlurScreenState();
}

class FaceBlurScreenState extends State<FaceBlurScreen> {
  final FaceBlurService _service = FaceBlurService();
  File? _imageFile;
  Uint8List? _processedImage;
  // ignore: prefer_final_fields
  List<String> _selectedParts = ['Left'];
  double _blurStrength = 66;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('얼굴 블러 처리'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('이미지 선택'),
                ),
                if (_imageFile != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_imageFile!),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '블러 강도: ${_blurStrength.round()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _blurStrength,
                    min: 60,
                    max: 80,
                    divisions: 10,
                    label: _blurStrength.round().toString(),
                    onChanged: (value) => setState(() => _blurStrength = value),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '블러 해제 영역:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: ['Left', 'Right', 'Mouth'].map((part) {
                        return CheckboxListTile(
                          title: Text(part),
                          value: _selectedParts.contains(part),
                          onChanged: (selected) {
                            setState(() {
                              if (selected ?? false) {
                                _selectedParts.add(part);
                              } else {
                                _selectedParts.remove(part);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _processImage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text(
                      '이미지 처리',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (_processedImage != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    '처리된 이미지:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(_processedImage!),
                  ),
                ],
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200, // 이미지 크기 제한
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _processedImage = null;
      });
    }
  }

  Future<void> _processImage() async {
    if (_imageFile == null) return;

    setState(() => _isLoading = true);

    try {
      final processedImage = await _service.processImage(
        imageFile: _imageFile!,
        unblurParts: _selectedParts,
        blurStrength: _blurStrength.round(),
      );

      setState(() {
        _processedImage = processedImage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      // 에러 메시지를 팝업으로 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('알림'),
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 팝업 닫기
                },
                child: const Text(
                  '닫기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
            elevation: 24,
          );
        },
        barrierDismissible: false, // 팝업 외부 터치로 닫히지 않도록 설정
      );
    }
  }
}
