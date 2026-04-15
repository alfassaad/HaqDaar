import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanAndPayScreen extends StatefulWidget {
  const ScanAndPayScreen({super.key});

  @override
  State<ScanAndPayScreen> createState() => _ScanAndPayScreenState();
}

class _ScanAndPayScreenState extends State<ScanAndPayScreen> {
  bool isScanCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Pay'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (!isScanCompleted) {
                final String code = capture.barcodes.first.rawValue ?? '---';
                isScanCompleted = true;
                context.go('/confirm-payment', extra: code);
              }
            },
          ),
          // Overlay with cutout
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Scan QR Code',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 280),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Add gallery picker logic
                  },
                  child: const Text('Pick from Gallery'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
