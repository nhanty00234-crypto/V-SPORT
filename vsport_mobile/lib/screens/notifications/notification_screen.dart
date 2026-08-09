import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/notification_service.dart';
import '../../widgets/common.dart';

/// Thông báo lấy từ bảng ThongBao của backend (booking, thanh toán, hoàn tiền, yêu cầu dịch vụ).
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<NotificationPage> _future;

  @override
  void initState() {
    super.initState();
    _future = NotificationService.instance.list(size: 50);
  }

  void _reload() => setState(() => _future = NotificationService.instance.list(size: 50));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          TextButton(
            onPressed: () async {
              await NotificationService.instance.markAllRead();
              _reload();
            },
            child: const Text('Đọc tất cả'),
          ),
        ],
      ),
      body: AsyncView<NotificationPage>(
        future: _future,
        onRetry: _reload,
        builder: (context, page) {
          if (page.items.isEmpty) return const EmptyState('Chưa có thông báo nào.');
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              itemCount: page.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final n = page.items[i];
                return ListTile(
                  leading: Icon(n.read ? Icons.mark_email_read_outlined : Icons.mark_email_unread,
                      color: n.read ? Colors.grey : Colors.blue),
                  title: Text(n.title ?? '',
                      style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(n.content ?? ''),
                  onTap: n.read
                      ? null
                      : () async {
                          await NotificationService.instance.markRead(n.notificationId);
                          _reload();
                        },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
