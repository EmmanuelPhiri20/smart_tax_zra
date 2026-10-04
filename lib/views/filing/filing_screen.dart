import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/dashboard_controller.dart';

class FilingScreen extends StatefulWidget {
  const FilingScreen({super.key});

  @override
  State<FilingScreen> createState() => _FilingScreenState();
}

class _FilingScreenState extends State<FilingScreen> {
  bool _loading = false;
  bool _serverOnline = false;
  bool _fileUploaded = false;
  bool _processing = false;
  double _uploadProgress = 0.0;
  double _processingProgress = 0.0;
  File? _selectedFile;
  List<List<dynamic>>? _csvData;
  int _anomalyCount = 0;
  int _normalCount = 0;
  String _processingMessage = '';

  // ---- Check API server before file selection ----
  Future<void> _checkServerHealth() async {
    setState(() => _loading = true);
    final health = await ApiService.checkServerHealth();
    setState(() {
      _loading = false;
      _serverOnline = health['status'];
    });

    if (!_serverOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server offline: ${health['error']}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _pickCSVFile();
  }

  // ---- Pick CSV file ----
  Future<void> _pickCSVFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileUploaded = false;
        _processing = false;
        _csvData = null;
        _uploadProgress = 0;
        _processingProgress = 0;
        _anomalyCount = 0;
        _normalCount = 0;
        _processingMessage = '';
      });
      _simulateUpload();
    }
  }

  // ---- Simulate upload progress visually ----
  Future<void> _simulateUpload() async {
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 40));
      setState(() => _uploadProgress = i / 100);
    }

    setState(() => _fileUploaded = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ CSV uploaded successfully. Ready for anomaly scan."),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ---- Scan CSV for anomalies via API ----
  Future<void> _scanForAnomalies() async {
    if (_selectedFile == null) return;

    setState(() {
      _loading = true;
      _processing = true;
      _processingProgress = 0;
      _processingMessage = 'Starting analysis...';
      _csvData = null;
    });

    try {
      print('🚀 Starting anomaly detection...');
      final response = await ApiService.uploadCSV(_selectedFile!);
      print('📊 Raw API Response: $response');

      final Map<String, dynamic> json = jsonDecode(response);
      print('📊 Parsed JSON: ${json['status']}');

      if (json['status'] == 'success') {
        // ✅ FIXED: Check if data exists and is a List
        final dynamic data = json['data'];
        List<dynamic> dataList = [];

        if (data is List) {
          dataList = data;
        } else if (data != null) {
          // If data is not a List but exists, wrap it in a List
          dataList = [data];
        }

        if (dataList.isEmpty) {
          throw Exception('No data returned from API');
        }

        // ✅ FIXED: Get headers from first item's keys
        final headers = dataList.first.keys.toList();

        // Convert to List<List<dynamic>> for DataTable
        final List<List<dynamic>> rows = [
          headers,
          ...dataList
              .map((e) => headers.map((h) => e[h]?.toString() ?? '').toList())
              .toList(),
        ];

        setState(() {
          _csvData = rows;

          // ✅ FIXED: Count anomalies safely
          final anomalyIndex = headers.indexOf('anomaly_flag');
          if (anomalyIndex != -1) {
            final flags = dataList
                .map((e) => e['anomaly_flag']?.toString() == '1')
                .toList();
            _anomalyCount = flags.where((f) => f == true).length;
            _normalCount = flags.where((f) => f == false).length;
          }

          _processing = false;
          _processingMessage = 'Analysis complete!';
        });

        // ✅ Update dashboard analytics in real-time
        Provider.of<DashboardController>(context, listen: false)
            .updateAnalytics(
          anomalyCount: _anomalyCount,
          normalCount: _normalCount,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('✅ Analysis complete: $_anomalyCount anomalies found'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API Error: ${json['message'] ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _processing = false;
          _processingMessage = 'Analysis failed';
        });
      }
    } catch (e) {
      print('❌ Scan error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scan failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _processing = false;
        _processingMessage = 'Analysis failed';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  // ---- Build processing indicator ----
  Widget _buildProcessingIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade400, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 2,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _processingMessage,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _processingProgress > 0 ? _processingProgress / 100 : null,
            backgroundColor: Colors.blue.shade200,
            color: Colors.blue.shade700,
          ),
          const SizedBox(height: 4),
          Text(
            'Processing... ${_processingProgress.toInt()}%',
            style: const TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  // ---- Build anomaly report table ----
  Widget _buildDataTable() {
    if (_csvData == null || _csvData!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "No data to display. Please scan a file first.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final headers = _csvData!.first;
    final dataRows = _csvData!.skip(1).toList();

    final displayRows = dataRows.take(50).toList();

    return DataTable(
      headingRowColor: WidgetStateProperty.all(const Color(0xFF013A80)),
      headingTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      dataTextStyle: const TextStyle(fontSize: 11),
      border: TableBorder.all(color: Colors.grey.shade300),
      columnSpacing: 20,
      horizontalMargin: 12,
      columns: headers
          .map((h) => DataColumn(
                label: Container(
                  constraints:
                      const BoxConstraints(minWidth: 100, maxWidth: 150),
                  child: Text(
                    _truncateText(h.toString(), 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ))
          .toList(),
      rows: displayRows.map((row) {
        final anomalyIndex = headers.indexOf('anomaly_flag');
        final isAnomaly =
            anomalyIndex != -1 && (row[anomalyIndex].toString() == '1');

        return DataRow(
          color: WidgetStateProperty.all(
            isAnomaly ? Colors.red.shade50 : Colors.green.shade50,
          ),
          cells: row.map((cell) {
            return DataCell(Container(
              constraints: const BoxConstraints(minWidth: 100, maxWidth: 150),
              child: Text(
                _truncateText(cell.toString(), 20),
                style: TextStyle(
                  color: isAnomaly ? Colors.red : Colors.green,
                  fontWeight: isAnomaly ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ));
          }).toList(),
        );
      }).toList(),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _getShortFileName() {
    if (_selectedFile == null) return '';
    final fullPath = _selectedFile!.path;
    final fileName = fullPath.split('/').last;
    if (fileName.length > 25) {
      return '${fileName.substring(0, 20)}...${fileName.substring(fileName.length - 5)}';
    }
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Tax Filing & Fraud Detection",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: true,
          overscroll: true,
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF013A80), Color(0xFF2980B9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.cloud_upload_rounded,
                          size: 40, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        "Upload Tax Records (CSV)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Scan for fraudulent or anomalous entries",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _checkServerHealth,
                    icon: const Icon(Icons.file_upload_outlined, size: 20),
                    label: const Text(
                      'Select CSV File',
                      style: TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF013A80),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_selectedFile != null && !_fileUploaded)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey.shade300,
                        color: const Color(0xFF013A80),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Uploading... ${(100 * _uploadProgress).toInt()}%",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                if (_fileUploaded && !_processing)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: Colors.green.shade400, width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green.shade700, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              "FILE READY FOR SCANNING",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getShortFileName(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Click 'Scan for Anomalies' to analyze this file",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_processing) _buildProcessingIndicator(),
                const SizedBox(height: 16),
                if (_fileUploaded && !_loading && !_processing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _scanForAnomalies,
                      icon: const Icon(Icons.search_rounded, size: 22),
                      label: const Text(
                        'SCAN FOR ANOMALIES',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                if (_loading && !_processing)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                            color: Color(0xFF013A80), strokeWidth: 2),
                        SizedBox(height: 8),
                        Text("Initializing...", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                if (_csvData != null && !_loading && !_processing)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _summaryCard("Anomalies", _anomalyCount, Colors.red),
                          _summaryCard("Normal", _normalCount, Colors.green),
                          _summaryCard("Total", _anomalyCount + _normalCount,
                              Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Detection Results (First 50 Records)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: MediaQuery.of(context).size.height *
                            0.6, // Fixed height for better scrolling
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            scrollbars: true,
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            trackVisibility: true,
                            thickness: 12, // Thicker scrollbar
                            radius: const Radius.circular(6),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Scrollbar(
                                thumbVisibility: true,
                                trackVisibility: true,
                                thickness: 12, // Thicker scrollbar
                                radius: const Radius.circular(6),
                                notificationPredicate: (notif) =>
                                    notif.depth == 1,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: _buildDataTable(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Extra space at bottom
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, int count, MaterialColor color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade400),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
