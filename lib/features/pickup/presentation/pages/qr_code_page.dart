import 'package:flutter/material.dart';

class QRCodePage extends StatelessWidget {
  final String pickupId;

  const QRCodePage({super.key, required this.pickupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
      ),
      body: Center(
        child: Text('QR Code Page - Pickup ID: $pickupId'),
      ),
    );
  }
}
