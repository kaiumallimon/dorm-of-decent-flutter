import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class MealReportGenerator {
  static Future<File?> generateMealReport({
    required String userName,
    required double totalMeals,
    required Map<String, double> mealsByDate,
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
            child: _MealReportWidget(
              userName: userName,
              totalMeals: totalMeals,
              mealsByDate: mealsByDate,
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

      final fileName = 'meal_report_${userName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      print('Error generating meal report: $e');
      return null;
    }
  }
}

class _MealReportWidget extends StatelessWidget {
  final String userName;
  final double totalMeals;
  final Map<String, double> mealsByDate;

  const _MealReportWidget({
    required this.userName,
    required this.totalMeals,
    required this.mealsByDate,
  });

  @override
  Widget build(BuildContext context) {
    // Sort dates in descending order
    final sortedEntries = mealsByDate.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    // Split into two columns
    final midPoint = (sortedEntries.length / 2).ceil();
    final leftColumn = sortedEntries.sublist(0, midPoint);
    final rightColumn = sortedEntries.length > midPoint
        ? sortedEntries.sublist(midPoint)
        : <MapEntry<String, double>>[];

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
          const SizedBox(height: 8),
          Text(
            DateFormat('MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(
              fontSize: 32,
              color: Colors.black54,
              fontFamily: 'Geist',
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Total Meals: ${totalMeals.toStringAsFixed(1)}',
            style: const TextStyle(
              fontSize: 28,
              color: Colors.black87,
              fontFamily: 'Geist',
            ),
          ),
          const SizedBox(height: 40),

          // Tables
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Table
              Expanded(
                child: _buildTable(leftColumn),
              ),
              const SizedBox(width: 24),
              // Right Table
              Expanded(
                child: rightColumn.isNotEmpty
                    ? _buildTable(rightColumn)
                    : const SizedBox.shrink(),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Footer
          const Text(
            '* This image is automatically generated through Dorm of Descent\'s application.',
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

  Widget _buildTable(List<MapEntry<String, double>> entries) {
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
                  flex: 3,
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
                  child: Text(
                    'Count',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Geist',
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          // Data Rows
          ...entries.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.white : Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      data.key,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontFamily: 'Geist',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      data.value % 1 == 0
                          ? data.value.toInt().toString()
                          : data.value.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontFamily: 'Geist',
                      ),
                      textAlign: TextAlign.right,
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
