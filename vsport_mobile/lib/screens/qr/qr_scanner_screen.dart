import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/models.dart';
import '../../services/api_client.dart';
import '../../services/qr_service.dart';
import '../../widgets/common.dart';
import 'qr_context_screen.dart';

/// Quét QR dán tại sân. Chuỗi quét được gửi nguyên vẹn cho backend để resolve —
/// app không tự suy ra sân/cơ sở từ nội dung mã.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  bool _handling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;
    await _resolve(raw);
  }

  Future<void> _resolve(String code) async {
    setState(() => _handling = true);
    try {
      final QrContext context0 = await QrService.instance.resolve(code);
      if (!mounted) return;
      if (!context0.available) {
        showSnack(context, context0.message ?? 'Mã QR không sử dụng được.', error: true);
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => QrContextScreen(context: context0)),
      );
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _handling = false);
    }
  }

  Future<void> _enterManually() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập mã sân'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Mã in dưới QR'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Xác nhận')),
        ],
      ),
    );
    if (code != null && code.isNotEmpty) await _resolve(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR tại sân'),
        actions: [
          IconButton(icon: const Icon(Icons.keyboard), onPressed: _enterManually, tooltip: 'Nhập mã thủ công'),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          if (_handling) const Center(child: CircularProgressIndicator()),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Hướng camera vào mã QR dán tại sân',
                style: TextStyle(color: Colors.white, backgroundColor: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
