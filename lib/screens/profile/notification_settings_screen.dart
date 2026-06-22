import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/services/profile_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _service = ProfileService();
  bool _push = true;
  bool _disease = true;
  bool _weekly = true;
  bool _tips = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = _service.uid;
    if (id == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get();
    final s = doc.data()?['notificationSettings'] as Map<String, dynamic>?;
    if (s != null && mounted) {
      setState(() {
        _push = s['push'] as bool? ?? true;
        _disease = s['diseaseAlerts'] as bool? ?? true;
        _weekly = s['weeklyReports'] as bool? ?? true;
        _tips = s['educationalTips'] as bool? ?? false;
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _persist() async {
    await _service.updateNotificationSettings({
      'push': _push,
      'diseaseAlerts': _disease,
      'weeklyReports': _weekly,
      'educationalTips': _tips,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF202422),
        title: const Text(
          'Notification Settings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _toggle(
                  'In-app Alerts',
                  'Show PLANTIVA alerts inside the app',
                  _push,
                  (v) {
                    setState(() => _push = v);
                    _persist();
                  },
                ),
                _toggle(
                  'Disease Alerts',
                  'Notify when diseases are detected',
                  _disease,
                  (v) {
                    setState(() => _disease = v);
                    _persist();
                  },
                ),
                _toggle(
                  'Weekly Plant Health Reports',
                  'Summary of your crop monitoring',
                  _weekly,
                  (v) {
                    setState(() => _weekly = v);
                    _persist();
                  },
                ),
                _toggle(
                  'Educational Tips',
                  'Farming tips and best practices',
                  _tips,
                  (v) {
                    setState(() => _tips = v);
                    _persist();
                  },
                ),
              ],
            ),
    );
  }

  Widget _toggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        value: value,
        activeThumbColor: AppColors.green,
        onChanged: onChanged,
      ),
    );
  }
}
