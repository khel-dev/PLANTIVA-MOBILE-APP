import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/classifier_service.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ClassifierService _classifier = ClassifierService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _classifier.loadModel();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() => _isLoading = true);

      final result = await _classifier.classify(File(pickedFile.path));

      setState(() => _isLoading = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imagePath: pickedFile.path,
              result: result,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background — dark green leaf effect
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A2A0A),
                  Color(0xFF1A4A1A),
                  Color(0xFF0A2A0A),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      Column(
                        children: [
                          const Text(
                            'PLANTIVA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 2,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'LIVE SENSOR',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.flash_auto,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Perfect lighting badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wb_sunny, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'PERFECT LIGHTING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Scanner frame
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.greenAccent.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Scanner placeholder
                            Container(
                              color: Colors.black.withOpacity(0.3),
                            ),

                            // Center focus icon
                            if (!_isLoading)
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.7),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.crop_free,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),

                            // Loading indicator
                            if (_isLoading)
                              const CircularProgressIndicator(
                                color: Colors.greenAccent,
                              ),

                            // Green scan line effect
                            Positioned(
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                color: Colors.greenAccent.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Instructions
                const Text(
                  'Align the banana leaf clearly in the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ensure adequate lighting and focus on\nareas with visible symptoms or discoloration.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Bottom buttons
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery button
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.photo_library_outlined,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'GALLERY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main capture button
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.camera),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.greenAccent.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.greenAccent,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.greenAccent,
                            size: 36,
                          ),
                        ),
                      ),

                      // Labs button
                      Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.science_outlined,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'LABS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _classifier.close();
    super.dispose();
  }
}