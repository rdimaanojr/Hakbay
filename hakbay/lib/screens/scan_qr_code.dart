import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Builder(
        builder: (context) {
          final size = MediaQuery.of(context).size;
          return Stack(
            children: [
              MobileScanner(
                onDetect: (capture) {
                  context.pop(capture.barcodes.first.rawValue);
                },
                scanWindow: Rect.fromCenter(
                  center: Offset(size.width / 2, size.height / 2),
                  width: size.width * 0.8,
                  height: size.height * 0.8,
                ),
              ),
              Center(
                child: Container(
                  width: size.width * 0.8,
                  height: size.width * 0.8,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
