import 'package:camcode/cam_code_scanner.dart';
import 'package:flutter/material.dart';

class CamCodeScannerPage extends StatefulWidget {
  final Function(String) onResult;

  CamCodeScannerPage(this.onResult);

  @override
  _CamCodeScannerPageState createState() => _CamCodeScannerPageState();
}

class _CamCodeScannerPageState extends State<CamCodeScannerPage> {
  /// Create a controller to send instructions to scanner
  final CamCodeScannerController _controller = CamCodeScannerController();

  /// List of availables cameras
  final List<String> cameraNames = [];

  /// currently selected camera
  late String _selectedCamera;

  @override
  void initState() {
    super.initState();
    _fetchDeviceList();
  }

  void _fetchDeviceList() async {
    /// Get list of available cameras
    final cameras = await _controller.fetchDeviceList();
    setState(() {
      cameraNames.addAll(cameras);
      _selectedCamera = cameras.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CamCodeScanner(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            refreshDelayMillis: 16,
            onBarcodeResult: (barcode) {
              Navigator.of(context).pop();
              widget.onResult(barcode);
            },
            controller: _controller,
            showDebugFrames: false,
            minimalResultCount: 1,
          ),
        ],
      ),
    );
  }
}
