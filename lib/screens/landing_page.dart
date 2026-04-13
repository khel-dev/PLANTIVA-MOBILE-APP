import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/screens/login.dart';
import 'package:flutter_plantiva/utils/page_transitions.dart';
import 'package:flutter_plantiva/widgets/logo_badge.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/banana_landing.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.35)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 38),
                          const LogoBadge(size: 175, withBackground: false),
                          const SizedBox(height: 20),
                          const Text(
                            'PLANTIVA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const Text(
                            'AI Plant Diagnosis',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 220,
                            child: PageView(
                              controller: _controller,
                              onPageChanged: (value) =>
                                  setState(() => _index = value),
                              children: const [
                                _LandingFeature(
                                  title: 'Detect leaf diseases instantly',
                                  text:
                                      'Take a photo of a banana leaf and let our AI detect diseases and give treatment steps immediately.',
                                ),
                                _LandingFeature(
                                  title: 'Track crop health with AI',
                                  text:
                                      'Store your scans, monitor progress over time, and get recommendations for healthier plants.',
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              2,
                              (dot) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: _index == dot ? 22 : 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: _index == dot
                                      ? Colors.white
                                      : Colors.white54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.green,
                              ),
                              onPressed: () => Navigator.of(context).push(
                                AppTransitions.fadeSlide(const LoginPage()),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(
                              context,
                            ).push(AppTransitions.fadeSlide(const LoginPage())),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingFeature extends StatelessWidget {
  const _LandingFeature({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      child: Column(
        key: ValueKey(title),
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.45,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
