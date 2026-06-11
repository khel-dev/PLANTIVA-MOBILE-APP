import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/screens/crop_wellness_screen.dart';
import 'package:flutter_plantiva/screens/disease_guide/disease_guide_screen.dart';
import 'package:flutter_plantiva/screens/notifications_screen.dart';
import 'package:flutter_plantiva/screens/profile.dart';
import 'package:flutter_plantiva/screens/scan_analytics_screen.dart';
import 'package:flutter_plantiva/screens/scan_history_screen.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/services/scan_history_service.dart';
import 'package:flutter_plantiva/screens/scanner_screen.dart';
import 'package:flutter_plantiva/utils/page_transitions.dart';
import 'package:flutter_plantiva/widgets/recent_scan_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _tabIndex = 0;
  late final AnimationController _introController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_fadeAnim);
    _introController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F5E9),
      body: SafeArea(child: _buildTabBody()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
        child: Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: AppColors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const ScannerScreen(),
                ),
              );
            },
            icon: const Icon(Icons.center_focus_strong, color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        index: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
      ),
    );
  }

  Widget _buildTabBody() {
    switch (_tabIndex) {
      case 1:
        return const _SavedScansTab();
      case 2:
        return const DiseaseGuideScreen();
      case 3:
        return const ProfilePage();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopGreeting(onProfileTap: () => setState(() => _tabIndex = 3)),
              const SizedBox(height: 14),
              const _HeroScanCard(),
              const SizedBox(height: 16),
              _HomeStatsRow(),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text(
                    'Recent Scans',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      color: Color(0xFF202422),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        AppTransitions.fadeSlide(const ScanHistoryScreen()),
                      );
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const _RecentScansFeed(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopGreeting extends StatelessWidget {
  const _TopGreeting({required this.onProfileTap});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: firestore.collection('users').doc(user?.uid).snapshots(),
              builder: (context, snapshot) {
                final userData =
                    snapshot.data?.data() as Map<String, dynamic>? ?? {};
                final fullName = userData['fullName'] ?? 'User';
                final firstName = fullName.split(' ').first;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good morning,',
                      style: TextStyle(color: Color(0xFF6C706E), fontSize: 14),
                    ),
                    Text(
                      firstName,
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppTransitions.fadeSlide(const NotificationsScreen()),
                );
              },
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 10),
          StreamBuilder<DocumentSnapshot>(
            stream: firestore.collection('users').doc(user?.uid).snapshots(),
            builder: (context, snap) {
              final photoUrl =
                  (snap.data?.data() as Map<String, dynamic>?)?['photoUrl']
                      as String?;
              return GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(photoUrl)
                      : const AssetImage('assets/images/profile_farmer.png')
                          as ImageProvider,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroScanCard extends StatelessWidget {
  const _HeroScanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 255,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        image: const DecorationImage(
          image: AssetImage('assets/images/banana_landing.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '✨ AI POWERED',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'Scan Banana Leaf',
              style: TextStyle(
                color: Colors.white,
                fontSize: 39,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Detect diseases instantly and get\nsmart treatment recommendations.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 17,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC400),
                  foregroundColor: const Color(0xFF232323),
                ),
                onPressed: () {Navigator.push(
                 context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
                );},
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text(
                  'Start Scan',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD0E9D4), width: 2),
            boxShadow: onTap != null
                ? [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withValues(alpha: 0.04),
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.green),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF222522),
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF7B817E), fontSize: 14),
          ),
          if (onTap != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'View details',
                  style: TextStyle(
                    color: AppColors.green.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.green.withValues(alpha: 0.9),
                ),
              ],
            ),
          ],
        ],
          ),
        ),
      ),
    );
  }
}

class _HomeStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.show_chart_rounded,
              value: '0',
              label: 'Total Scans',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.shield_outlined,
              value: '—',
              label: 'Plant Health',
            ),
          ),
        ],
      );
    }

    final firestore = FirebaseFirestore.instance;
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('users').doc(user.uid).snapshots(),
      builder: (context, userSnap) {
        final u = userSnap.data?.data() as Map<String, dynamic>? ?? {};
        final total = (u['totalScans'] as num?)?.toInt() ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('users')
              .doc(user.uid)
              .collection('scans')
              .orderBy('createdAt', descending: true)
              .limit(24)
              .snapshots(),
          builder: (context, scanSnap) {
            var healthy = 0;
            var n = 0;
            if (scanSnap.hasData) {
              for (final doc in scanSnap.data!.docs) {
                final m = doc.data() as Map<String, dynamic>?;
                final lab = (m?['label'] as String?)?.toLowerCase() ?? '';
                if (lab.contains('healthy')) healthy++;
                n++;
              }
            }
            final healthPct =
                n == 0 ? null : ((healthy / n) * 100).round().clamp(0, 100);

            return Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.show_chart_rounded,
                    value: total.toString(),
                    label: 'Total Scans',
                    onTap: () {
                      Navigator.of(context).push(
                        AppTransitions.fadeSlide(
                          const ScanAnalyticsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.shield_outlined,
                    value: healthPct == null ? '—' : '$healthPct%',
                    label: 'Healthy (recent)',
                    onTap: () {
                      Navigator.of(context).push(
                        AppTransitions.fadeSlide(
                          const CropWellnessScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RecentScansFeed extends StatelessWidget {
  const _RecentScansFeed();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScanRecord>>(
      stream: ScanHistoryService.watchScans(limit: 5),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final scans = snap.data ?? [];
        if (scans.isEmpty) return const RecentScansEmptyState();

        return Column(
          children: [
            for (var i = 0; i < scans.length; i++)
              RecentScanCard(
                scan: scans[i],
                animationDelay: i * 50,
                enableSwipeDelete: false,
              ),
          ],
        );
      },
    );
  }
}

class _SavedScansTab extends StatelessWidget {
  const _SavedScansTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Saved scans',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    color: Color(0xFF202422),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    AppTransitions.fadeSlide(const ScanHistoryScreen()),
                  );
                },
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Your complete diagnosis history with captured leaf images.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<ScanRecord>>(
              stream: ScanHistoryService.watchScans(limit: 50),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.data!.isEmpty) {
                  return const Center(child: RecentScansEmptyState());
                }
                return ListView.builder(
                  itemCount: snap.data!.length,
                  itemBuilder: (context, i) => RecentScanCard(
                    scan: snap.data![i],
                    animationDelay: (i % 5) * 40,
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

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 12,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      child: SizedBox(
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              active: index == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.bookmark_border,
              label: 'Saved',
              active: index == 1,
              onTap: () => onTap(1),
            ),
            const SizedBox(width: 38),
            _NavItem(
              icon: Icons.menu_book_outlined,
              label: 'Diseases',
              active: index == 2,
              onTap: () => onTap(2),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              active: index == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.green : const Color(0xFF737874);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
