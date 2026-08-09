import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_client.dart';

final NumberFormat vnd = NumberFormat.decimalPattern('vi_VN');

String formatMoney(num? amount) => amount == null ? '—' : '${vnd.format(amount)}đ';

String formatDate(String isoDate) {
  try {
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(isoDate));
  } catch (_) {
    return isoDate;
  }
}

void showSnack(BuildContext context, String message, {bool error = false}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red.shade700 : null,
    ));
}

/// Bọc một Future và hiển thị loading / lỗi / dữ liệu — dùng chung cho mọi màn hình đọc API,
/// nhờ đó việc xử lý mất mạng và lỗi server chỉ viết một lần.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.future, required this.builder, this.onRetry});

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is ApiException ? error.message : 'Đã xảy ra lỗi: $error';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.center),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
                  ],
                ],
              ),
            ),
          );
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        ),
      );
}

/// Nhãn trạng thái đặt sân, màu theo nhóm trạng thái của backend.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final s = status ?? '';
    Color color;
    switch (s) {
      case 'Đã xác nhận':
      case 'Đã hoàn thành':
        color = Colors.green;
        break;
      case 'Chờ thanh toán':
        color = Colors.orange;
        break;
      case 'Chờ xác nhận':
        color = Colors.blue;
        break;
      case 'Đã hủy':
      case 'Quá hạn':
      case 'Không đến':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(s, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

/// Ảnh từ API — luôn có fallback vì backend có thể trả null cho ảnh chưa cấu hình.
class RemoteImage extends StatelessWidget {
  const RemoteImage({super.key, this.url, this.width = 64, this.height = 64});

  final String? url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Icon(Icons.sports_tennis, color: Colors.grey),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}
