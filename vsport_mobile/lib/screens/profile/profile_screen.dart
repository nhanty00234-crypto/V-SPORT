import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../widgets/common.dart';
import '../auth/login_screen.dart';
import '../notifications/notification_screen.dart';

/// Hồ sơ khách hàng: xem/sửa các trường mà Web cũng cho phép sửa, và đăng xuất.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Customer> _future;

  @override
  void initState() {
    super.initState();
    _future = AuthService.instance.me();
  }

  void _reload() => setState(() => _future = AuthService.instance.me());

  Future<void> _edit(Customer c) async {
    final nameController = TextEditingController(text: c.fullName ?? '');
    final phoneController = TextEditingController(text: c.phone ?? '');
    String? gender = c.gender;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Cập nhật hồ sơ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ tên')),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: (gender == 'Nam' || gender == 'Nữ' || gender == 'Khác') ? gender : null,
                decoration: const InputDecoration(labelText: 'Giới tính'),
                items: const [
                  DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                  DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                  DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                ],
                onChanged: (v) => setLocal(() => gender = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Đóng')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
          ],
        ),
      ),
    );
    if (saved != true) return;

    try {
      await AuthService.instance.updateProfile(
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        gender: gender,
      );
      if (!mounted) return;
      showSnack(context, 'Đã cập nhật hồ sơ.');
      _reload();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: AsyncView<Customer>(
        future: _future,
        onRetry: _reload,
        builder: (context, c) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: (c.avatar != null && c.avatar!.isNotEmpty) ? NetworkImage(c.avatar!) : null,
                child: (c.avatar == null || c.avatar!.isEmpty) ? const Icon(Icons.person, size: 40) : null,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(c.fullName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            ListTile(leading: const Icon(Icons.email_outlined), title: Text(c.email ?? '—')),
            ListTile(leading: const Icon(Icons.phone_outlined), title: Text(c.phone ?? '—')),
            ListTile(leading: const Icon(Icons.wc_outlined), title: Text(c.gender ?? '—')),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: Text('Điểm uy tín: ${c.reputationScore}'),
              subtitle: Text(c.reputationLabel ?? ''),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Thông báo'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Cập nhật hồ sơ'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _edit(c),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
