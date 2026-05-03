import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

class ScanAndPayScreen extends StatefulWidget {
  const ScanAndPayScreen({super.key});

  @override
  State<ScanAndPayScreen> createState() => _ScanAndPayScreenState();
}

class _ScanAndPayScreenState extends State<ScanAndPayScreen> {
  bool isScanCompleted = false;
  final MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _processCode(String rawCode) {
    if (isScanCompleted) return;

    try {
      final decoded = jsonDecode(rawCode);
      if (decoded['type'] == 'haqdaar_v1' && decoded['id'] != null) {
        isScanCompleted = true;
        controller.stop();
        context.go('/confirm-payment', extra: decoded['id']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid HaqDaar QR Code')),
        );
      }
    } catch (e) {
      // Fallback for legacy raw ID codes if needed, or just show error
      if (rawCode.isNotEmpty && !rawCode.contains('{')) {
        isScanCompleted = true;
        controller.stop();
        context.go('/confirm-payment', extra: rawCode);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not recognize QR code format')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Pay'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (!isScanCompleted) {
                final String code = capture.barcodes.first.rawValue ?? '';
                if (code.isNotEmpty) {
                  _processCode(code);
                }
              }
            },
          ),
          // Overlay with cutout
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha((0.5 * 255).toInt()),
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
                ElevatedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (!mounted) return;
                    if (image != null) {
                      final barcodes = await controller.analyzeImage(image.path);
                      if (!mounted) return;
                      
                      if (barcodes != null && barcodes.barcodes.isNotEmpty) {
                        final String code = barcodes.barcodes.first.rawValue ?? '';
                        _processCode(code);
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('No QR code found in image')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Pick from Gallery'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
