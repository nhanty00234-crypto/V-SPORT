import 'package:flutter/material.dart';

import '../../models/models.dart' as m;
import '../../services/api_client.dart';
import '../../services/qr_service.dart';
import '../../widgets/common.dart';

/// Sau khi quét QR: hiển thị đúng cơ sở/sân và cho phép gửi yêu cầu tới nhân viên.
/// Yêu cầu đi thẳng vào bảng QRRequest — Staff/Manager trên web nhận được ngay.
class QrContextScreen extends StatefulWidget {
  const QrContextScreen({super.key, required this.context});

  final m.QrContext context;

  @override
  State<QrContextScreen> createState() => _QrContextScreenState();
}

class _QrContextScreenState extends State<QrContextScreen> {
  late Future<List<m.ServiceRequest>> _requests;
  bool _sending = false;

  final Map<int, int> _cart = {};

  String get _token => widget.context.sessionToken ?? '';

  @override
  void initState() {
    super.initState();
    _requests = QrService.instance.myRequests(_token);
  }

  void _reloadRequests() => setState(() => _requests = QrService.instance.myRequests(_token));

  Future<void> _send(String type, {String? note, List<Map<String, int>>? items}) async {
    setState(() => _sending = true);
    try {
      await QrService.instance.createRequest(sessionToken: _token, type: type, note: note, items: items);
      if (!mounted) return;
      showSnack(context, 'Đã gửi yêu cầu tới nhân viên.');
      _cart.clear();
      _reloadRequests();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _callStaff() async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gọi nhân viên'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nội dung cần hỗ trợ (tuỳ chọn)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Gửi')),
        ],
      ),
    );
    if (note != null) await _send('CALL_STAFF', note: note.isEmpty ? null : note);
  }

  Future<void> _requestPayment() async {
    final method = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Yêu cầu thanh toán'),
        children: [
          SimpleDialogOption(onPressed: () => Navigator.pop(context, 'Tiền mặt'), child: const Text('Tiền mặt')),
          SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Chuyển khoản'), child: const Text('Chuyển khoản')),
        ],
      ),
    );
    if (method != null) await _send('PAYMENT_REQUEST', note: method);
  }

  Future<void> _orderItems() async {
    if (_cart.isEmpty) {
      showSnack(context, 'Vui lòng chọn ít nhất một món.', error: true);
      return;
    }
    final items = _cart.entries.map((e) => {'sanPhamId': e.key, 'soLuong': e.value}).toList();
    await _send('ORDER_ITEM', items: items);
  }

  @override
  Widget build(BuildContext context) {
    final ctx = widget.context;
    final actions = ctx.availableActions;
    return Scaffold(
      appBar: AppBar(title: const Text('Tại sân')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(ctx.facilityName ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('${ctx.courtName ?? ''}${ctx.sportName != null ? ' · ${ctx.sportName}' : ''}'),
          Text(ctx.activeBookingId != null ? 'Đang có phiên sử dụng #${ctx.activeBookingId}' : 'Sân đang trống',
              style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (actions.contains('CALL_STAFF'))
                FilledButton.icon(
                  onPressed: _sending ? null : _callStaff,
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Gọi nhân viên'),
                ),
              if (actions.contains('PAYMENT_REQUEST'))
                OutlinedButton.icon(
                  onPressed: _sending ? null : _requestPayment,
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Yêu cầu thanh toán'),
                ),
            ],
          ),
          if (actions.contains('ORDER_ITEM') && ctx.products.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Gọi món / dịch vụ', style: TextStyle(fontWeight: FontWeight.bold)),
            ...ctx.products.map((p) {
              final qty = _cart[p.productId] ?? 0;
              return ListTile(
                dense: true,
                title: Text(p.name),
                subtitle: Text('${formatMoney(p.price)} · còn ${p.stock}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: qty == 0
                          ? null
                          : () => setState(() {
                                if (qty <= 1) {
                                  _cart.remove(p.productId);
                                } else {
                                  _cart[p.productId] = qty - 1;
                                }
                              }),
                    ),
                    Text('$qty'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: qty >= p.stock ? null : () => setState(() => _cart[p.productId] = qty + 1),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _sending ? null : _orderItems,
              child: const Text('Gửi đơn gọi món'),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Yêu cầu của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(onPressed: _reloadRequests, child: const Text('Làm mới')),
            ],
          ),
          AsyncView<List<m.ServiceRequest>>(
            future: _requests,
            onRetry: _reloadRequests,
            builder: (context, items) {
              if (items.isEmpty) return const EmptyState('Chưa gửi yêu cầu nào tại sân này.');
              return Column(
                children: items
                    .map((r) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.receipt_long_outlined),
                          title: Text(r.type ?? ''),
                          subtitle: Text(r.note ?? ''),
                          trailing: Text(r.status ?? ''),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
