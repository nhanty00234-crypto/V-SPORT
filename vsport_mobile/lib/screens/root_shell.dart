import 'package:flutter/material.dart';

import 'booking/booking_history_screen.dart';
import 'facility/facility_list_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'qr/qr_scanner_screen.dart';

/// Khung điều hướng chính: Trang chủ · Tìm sân · QR · Lịch đặt · Tài khoản.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  static const route = '/home';

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    FacilityListScreen(),
    QrScannerScreen(),
    BookingHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Tìm sân'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Quét QR'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Lịch đặt'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}
