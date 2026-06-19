import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/screens/landing_page.dart';
import 'package:flutter_plantiva/screens/profile/help_center_screen.dart';
import 'package:flutter_plantiva/screens/profile/notification_settings_screen.dart';
import 'package:flutter_plantiva/screens/profile/privacy_security_screen.dart';
import 'package:flutter_plantiva/services/auth_service.dart';
import 'package:flutter_plantiva/services/profile_service.dart';
import 'package:flutter_plantiva/utils/validators.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late Animation<double> _fadeAnim;

  final _authService = AuthService();
  final _profileService = ProfileService();

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
    _introController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  void _showPhotoSheet(String? currentUrl) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _sheetOption(
                ctx,
                Icons.camera_alt_outlined,
                'Take Photo',
                () async {
                  Navigator.pop(ctx);
                  await _profileService.pickAndUploadPhoto(ImageSource.camera);
                },
              ),
              _sheetOption(
                ctx,
                Icons.photo_library_outlined,
                'Choose from Gallery',
                () async {
                  Navigator.pop(ctx);
                  await _profileService.pickAndUploadPhoto(ImageSource.gallery);
                },
              ),
              if (currentUrl != null && currentUrl.isNotEmpty)
                _sheetOption(
                  ctx,
                  Icons.delete_outline,
                  'Remove Photo',
                  () async {
                    Navigator.pop(ctx);
                    await _profileService.removePhoto();
                  },
                  isDestructive: true,
                ),
              _sheetOption(
                  ctx, Icons.close, 'Cancel', () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetOption(
    BuildContext ctx,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.green),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : const Color(0xFF202422),
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F5E9),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: StreamBuilder<DocumentSnapshot>(
            stream: _profileService.userStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final userData =
                  snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final storedName = (userData['fullName'] as String?)?.trim();
              final authName =
                  FirebaseAuth.instance.currentUser?.displayName?.trim();
              final fullName = storedName?.isNotEmpty == true
                  ? storedName!
                  : authName?.isNotEmpty == true
                      ? authName!
                      : 'Plantiva User';
              final email = userData['email'] as String? ??
                  FirebaseAuth.instance.currentUser?.email ??
                  '';
              final contact = userData['phoneNumber'] as String? ??
                  userData['contactNumber'] as String? ??
                  '';
              final location = userData['location'] as String? ??
                  userData['farmLocation'] as String? ??
                  '';
              final photoUrl = userData['photoUrl'] as String?;
              final totalScans = (userData['totalScans'] as num?)?.toInt() ?? 0;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF202422),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ProfileHeaderCard(
                      fullName: fullName,
                      email: email,
                      photoUrl: photoUrl,
                      totalScans: totalScans,
                      onPhotoTap: () => _showPhotoSheet(photoUrl),
                    ),
                    const SizedBox(height: 20),
                    _ProfileInfoCard(
                      fullName: fullName,
                      email: email,
                      contact: contact,
                      location: location,
                      onSave: (name, phone, loc) async {
                        await _profileService.updateProfile(
                          fullName: name,
                          contactNumber: phone,
                          farmLocation: loc,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202422),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notification Settings',
                      subtitle: 'Alerts, updates & reminders',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center',
                      subtitle: 'FAQs and support',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const HelpCenterScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SettingsTile(
                      icon: Icons.security_rounded,
                      title: 'Privacy & Security',
                      subtitle: 'Manage your data and access',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const PrivacySecurityScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LogoutTile(
                      onTap: () {
                        final nav = Navigator.of(context);
                        showDialog<void>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Sign Out?'),
                            content: const Text(
                              'Are you sure you want to sign out?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(dialogContext);
                                  await _authService.signOut();
                                  if (context.mounted) {
                                    nav.pushAndRemoveUntil(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const LandingPage(),
                                      ),
                                      (_) => false,
                                    );
                                  }
                                },
                                child: const Text(
                                  'Sign Out',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.fullName,
    required this.email,
    required this.photoUrl,
    required this.totalScans,
    required this.onPhotoTap,
  });

  final String fullName;
  final String email;
  final String? photoUrl;
  final int totalScans;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'profile_photo',
            child: GestureDetector(
              onTap: onPhotoTap,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: photoUrl != null && photoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: photoUrl!,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _defaultAvatar(),
                            errorWidget: (_, __, ___) => _defaultAvatar(),
                          )
                        : _defaultAvatar(),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF202422),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$totalScans scans completed',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Image.asset(
      'assets/images/profile_farmer.png',
      width: 88,
      height: 88,
      fit: BoxFit.cover,
    );
  }
}

class _ProfileInfoCard extends StatefulWidget {
  const _ProfileInfoCard({
    required this.fullName,
    required this.email,
    required this.contact,
    required this.location,
    required this.onSave,
  });

  final String fullName;
  final String email;
  final String contact;
  final String location;
  final Future<void> Function(String name, String phone, String loc) onSave;

  @override
  State<_ProfileInfoCard> createState() => _ProfileInfoCardState();
}

class _ProfileInfoCardState extends State<_ProfileInfoCard> {
  late final TextEditingController _name;
  late final TextEditingController _contact;
  late final TextEditingController _location;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.fullName);
    _contact = TextEditingController(text: widget.contact);
    _location = TextEditingController(text: widget.location);
  }

  @override
  void didUpdateWidget(covariant _ProfileInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing) {
      _name.text = widget.fullName;
      _contact.text = widget.contact;
      _location.text = widget.location;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _editing = !_editing),
                child: Text(_editing ? 'Cancel' : 'Edit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _field('Full Name', _name, enabled: _editing),
          _readOnly('Email Address', widget.email),
          _field('Contact Number', _contact, enabled: _editing),
          _field('Province / Location', _location, enabled: _editing),
          if (_editing) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        final phoneErr = _contact.text.trim().isEmpty
                            ? null
                            : Validators.phone(_contact.text);
                        if (phoneErr != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(phoneErr)),
                          );
                          return;
                        }
                        setState(() => _saving = true);
                        await widget.onSave(
                          _name.text.trim(),
                          _contact.text.trim(),
                          _location.text.trim(),
                        );
                        if (mounted) {
                          setState(() {
                            _saving = false;
                            _editing = false;
                          });
                        }
                      },
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: enabled ? const Color(0xFFF8F9F8) : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _readOnly(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        enabled: false,
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatefulWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.98).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: AppColors.green, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFFC0C0C0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatefulWidget {
  const _LogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_LogoutTile> createState() => _LogoutTileState();
}

class _LogoutTileState extends State<_LogoutTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.98).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCDD2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFC62828),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC62828),
                      ),
                    ),
                    Text(
                      'Sign out of your account',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE57373),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFEF9A9A),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
