import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/DAMS/controller/scan_controller.dart';
import 'asset_form_page.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});
  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  final ScanController _scanController = Get.put(ScanController());
  bool _isLoading = false;
  MobileScannerController? _mobileScannerController;

  @override
  void initState() {
    super.initState();
    _mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _mobileScannerController?.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodes) async {
    if (barcodes.barcodes.isEmpty || _isLoading) return;

    final barcode = barcodes.barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() => _isLoading = true);

    try {
      // Stop the camera first
      await _mobileScannerController?.stop();

      // First verify the asset exists by fetching it
      await _scanController.getAssetByKodeAset(barcode.rawValue!);

      // If successful, navigate to form page with the kodeAset
      if (mounted) {
        Get.to(() => AssetFormPage(kodeAset: barcode.rawValue!));
      }
    } catch (e) {
      // Restart the camera if there's an error
      if (mounted) {
        await _mobileScannerController?.start();
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code Asset')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _handleBarcode,
            controller: _mobileScannerController,
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
