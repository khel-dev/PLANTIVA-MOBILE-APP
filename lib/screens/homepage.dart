import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/screens/profile.dart';
import 'package:flutter_plantiva/screens/scanner_screen.dart';

String _formatScanTime(Timestamp? t) {
  if (t == null) return '';
  final d = t.toDate();
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  String two(int n) => n.toString().padLeft(2, '0');
  return '${months[d.month - 1]} ${d.day}, ${two(d.hour)}:${two(d.minute)}';
}

({Color chipColor, Color chipTextColor}) _chipsForScanLabel(String label) {
  final l = label.toLowerCase();
  if (l.contains('healthy')) {
    return (
      chipColor: const Color(0xFFE8F5E9),
      chipTextColor: const Color(0xFF2E7D32),
    );
  }
  if (l.contains('yellow sigatoka') || l.contains('sigatoka')) {
    return (
      chipColor: const Color(0xFFFFF9C4),
      chipTextColor: const Color(0xFFF57F17),
    );
  }
  if (l.contains('panama')) {
    return (
      chipColor: const Color(0xFFFFF3E0),
      chipTextColor: const Color(0xFFEF6C00),
    );
  }
  if (l.contains('moko')) {
    return (
      chipColor: const Color(0xFFFFEBEE),
      chipTextColor: const Color(0xFFC62828),
    );
  }
  if (l.contains('mosaic') || l.contains('virus')) {
    return (
      chipColor: const Color(0xFFF3E5F5),
      chipTextColor: const Color(0xFF6A1B9A),
    );
  }
  if (l.contains('insect')) {
    return (
      chipColor: const Color(0xFFE0F7FA),
      chipTextColor: const Color(0xFF00695C),
    );
  }
  return (
    chipColor: const Color(0xFFFFEBEE),
    chipTextColor: const Color(0xFFC62828),
  );
}

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
        return const _DiseasesGuideTab();
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
              const _TopGreeting(),
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
                    onPressed: () => setState(() => _tabIndex = 1),
                    child: const Text(
                      'See all',
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
  const _TopGreeting();

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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Field alerts will appear here in a future update.'),
                  ),
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
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/plantiva_logo.png'),
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
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD0E9D4), width: 2),
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
        ],
      ),
    );
  }
}

class _RecentScanTile extends StatelessWidget {
  const _RecentScanTile({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.image,
    required this.chipColor,
    required this.chipTextColor,
  });

  final String title;
  final String subtitle;
  final String status;
  final String image;
  final Color chipColor;
  final Color chipTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(image, width: 64, height: 64, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF232625),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF818683),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: chipColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: chipTextColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
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
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.shield_outlined,
                    value: healthPct == null ? '—' : '$healthPct%',
                    label: 'Healthy (recent)',
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const _EmptyScansHint();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .orderBy('createdAt', descending: true)
          .limit(6)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const _EmptyScansHint();
        }

        return Column(
          children: snap.data!.docs.map((doc) {
            final m = doc.data()! as Map<String, dynamic>;
            final label = m['label'] as String? ?? 'Unknown';
            final conf = m['confidence'] as String? ?? '';
            final ts = m['createdAt'] as Timestamp?;
            final chips = _chipsForScanLabel(label);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecentScanTile(
                title: label,
                subtitle: _formatScanTime(ts),
                status: conf.isEmpty ? 'Done' : conf,
                image: 'assets/images/banana_landing.jpg',
                chipColor: chips.chipColor,
                chipTextColor: chips.chipTextColor,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _EmptyScansHint extends StatelessWidget {
  const _EmptyScansHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0E9D4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco_outlined, color: AppColors.green.withValues(alpha: 0.9)),
              const SizedBox(width: 10),
              const Text(
                'No scans yet',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: Color(0xFF232625),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Use the center scan button to analyze a banana leaf. Results sync to your history automatically.',
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.45,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedScansTab extends StatelessWidget {
  const _SavedScansTab();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saved scans',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: Color(0xFF202422),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Stored in your Firebase account (label & confidence only).',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: user == null
                ? const Center(child: Text('Sign in to view scans.'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('scans')
                        .orderBy('createdAt', descending: true)
                        .limit(50)
                        .snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No saved scans yet.'),
                        );
                      }
                      return ListView.separated(
                        itemCount: snap.data!.docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final m =
                              snap.data!.docs[i].data() as Map<String, dynamic>;
                          final label = m['label'] as String? ?? '';
                          final conf = m['confidence'] as String? ?? '';
                          final ts = m['createdAt'] as Timestamp?;
                          final chips = _chipsForScanLabel(label);
                          return _RecentScanTile(
                            title: label,
                            subtitle: _formatScanTime(ts),
                            status: conf.isEmpty ? '—' : conf,
                            image: 'assets/images/banana_login.jpg',
                            chipColor: chips.chipColor,
                            chipTextColor: chips.chipTextColor,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DiseasesGuideTab extends StatelessWidget {
  const _DiseasesGuideTab();

  @override
  Widget build(BuildContext context) {
    const items = <_GuideEntry>[
      _GuideEntry(
        'Black Sigatoka',
        'Dark streaks and spots on leaves; reduces yield if untreated.',
      ),
      _GuideEntry(
        'Yellow Sigatoka',
        'Yellowish streaks — often appears before black sigatoka in the field.',
      ),
      _GuideEntry(
        'Panama disease',
        'Fusarium wilt — soil-borne; no chemical cure. Use clean planting material.',
      ),
      _GuideEntry(
        'Moko disease',
        'Bacterial wilt — destroy infected mats and disinfect tools.',
      ),
      _GuideEntry(
        'Bract mosaic virus',
        'Virus spread by aphids; mosaic patterns on bracts and leaves.',
      ),
      _GuideEntry(
        'Insect pest damage',
        'Chewing or stippling from thrips, weevils, or other pests.',
      ),
      _GuideEntry(
        'Healthy leaf',
        'Your model’s baseline — strong greens, minimal lesions.',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      children: [
        const Text(
          'Banana diseases',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: Color(0xFF202422),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Quick reference for the classes your TFLite model predicts.',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        const SizedBox(height: 14),
        for (final e in items) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD0E9D4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: Color(0xFF1B4332),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  e.blurb,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.45,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _GuideEntry {
  const _GuideEntry(this.title, this.blurb);
  final String title;
  final String blurb;
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
