import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class BillReportGenerator {
  static Future<File?> generateBillReport({
    required String userName,
    required double totalAmount,
    required List<Map<String, dynamic>> bills,
    required BuildContext context,
  }) async {
    try {
      final key = GlobalKey();

      // Show the widget in an overlay to render it
      final overlay = OverlayEntry(
        builder: (context) => Positioned(
          left: -10000, // Offscreen
          top: -10000,
          child: RepaintBoundary(
            key: key,
            child: _BillReportWidget(
              userName: userName,
              totalAmount: totalAmount,
              bills: bills,
            ),
          ),
        ),
      );

      final overlayState = Overlay.of(context);
      overlayState.insert(overlay);

      // Wait for the widget to be rendered
      await Future.delayed(const Duration(milliseconds: 100));

      // Capture the image
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Remove the overlay
      overlay.remove();

      // Save to file in a publicly accessible location
      Directory directory;

      if (Platform.isAndroid) {
        // For Android, save to Downloads folder
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback to external storage
          final extDir = await getExternalStorageDirectory();
          directory = Directory('${extDir!.path}/Download');
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        }
      } else {
        // For iOS and other platforms, use documents directory
        directory = await getApplicationDocumentsDirectory();
      }

      final fileName = 'bill_report_${userName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      return null;
    }
  }
}

class _BillReportWidget extends StatelessWidget {
  final String userName;
  final double totalAmount;
  final List<Map<String, dynamic>> bills;

  const _BillReportWidget({
    required this.userName,
    required this.totalAmount,
    required this.bills,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      padding: const EdgeInsets.all(40),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            userName,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Geist',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Total Amount Spent: BDT ${totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFF6B7280),
              fontFamily: 'Geist',
            ),
          ),
          const SizedBox(height: 40),

          // Table
          _buildBillTable(),

          const SizedBox(height: 40),

          // Footer
          const Text(
            '* This image is automatically generated through Dorm of Descent\'s website.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontFamily: 'Geist',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Geist',
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Geist',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Geist',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          // Data Rows
          ...bills.asMap().entries.map((entry) {
            final index = entry.key;
            final bill = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.white : Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      bill['date'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontFamily: 'Geist',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'BDT ${bill['amount']}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontFamily: 'Geist',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      bill['description'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontFamily: 'Geist',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
