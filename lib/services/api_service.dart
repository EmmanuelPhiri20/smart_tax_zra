import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.96.94.245:8000";

  /// 📤 Upload CSV for anomaly detection - IMPROVED
  static Future<String> uploadCSV(File file) async {
    final uri = Uri.parse('$baseUrl/batch');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
            onTimeout: () =>
                throw TimeoutException('Upload request timed out.'),
          );

      final response = await http.Response.fromStream(streamedResponse);
      print('📥 Server response: ${response.statusCode}');
      print(
          '🔍 Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        final body = response.body.trim();

        // 🧠 Detect CSV vs JSON
        if (body.startsWith('{') || body.startsWith('[')) {
          print('✅ JSON detected');
          return body;
        } else if (body.startsWith('tpin') || body.contains(',')) {
          print('🧾 CSV detected — converting to JSON list');

          final lines =
              body.split('\n').where((l) => l.trim().isNotEmpty).toList();
          final headers = lines.first.split(',');
          final dataRows = lines.skip(1);

          final jsonList = dataRows.map((line) {
            final values = line.split(',');
            final map = <String, dynamic>{};
            for (int i = 0; i < headers.length && i < values.length; i++) {
              map[headers[i]] = values[i].replaceAll('"', '');
            }
            return map;
          }).toList();

          return jsonEncode({
            "status": "success",
            "data": jsonList,
          });
        } else {
          throw Exception("Unknown response format");
        }
      } else {
        final errorData = _safeJsonDecode(response.body);
        final errorMessage =
            errorData['message'] ?? errorData['error'] ?? response.reasonPhrase;
        throw Exception('Server error (${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      print('💥 Upload failed with error: $e');
      throw Exception('Upload failed: $e');
    }
  }

  /// ==========================
  /// 🔄 Poll for processing results
  /// ==========================
  static Future<String> _pollForResults(String requestId) async {
    final statusUri = Uri.parse('$baseUrl/batch/status/$requestId');
    int attempts = 0;
    const maxAttempts = 60; // 5 minutes max (60 * 5 seconds)

    while (attempts < maxAttempts) {
      try {
        await Future.delayed(
            const Duration(seconds: 5)); // Check every 5 seconds
        attempts++;

        print('🔄 Checking processing status (attempt $attempts)...');
        final response =
            await http.get(statusUri).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final statusData = _safeJsonDecode(response.body);

          if (statusData['status'] == 'completed') {
            print('✅ Processing completed!');
            return jsonEncode(statusData);
          } else if (statusData['status'] == 'processing') {
            final progress = statusData['progress'] ?? 0;
            print('📊 Processing progress: $progress%');
            // Continue polling
          } else if (statusData['status'] == 'error') {
            throw Exception('Processing failed: ${statusData['message']}');
          }
        } else {
          throw Exception('Status check failed: ${response.statusCode}');
        }
      } on TimeoutException {
        print('⏱️ Status check timed out, retrying...');
        continue;
      } catch (e) {
        print('❌ Status check error: $e');
        rethrow;
      }
    }

    throw Exception(
        'Processing took too long. Please try again with a smaller file.');
  }

  /// ==========================
  /// 🔮 Single JSON prediction
  /// ==========================
  static Future<Map<String, dynamic>> predictSingle(
      Map<String, dynamic> jsonData) async {
    final uri = Uri.parse('$baseUrl/predict');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(jsonData),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return _safeJsonDecode(response.body);
      } else {
        final errorData = _safeJsonDecode(response.body);
        throw Exception(
            'Prediction failed: ${errorData['error'] ?? response.reasonPhrase}');
      }
    } on SocketException {
      throw Exception(
          "Cannot connect to API server. Check if it's running on $baseUrl");
    } on TimeoutException {
      throw Exception("⏱️ Prediction request timed out. Try again.");
    } catch (e) {
      throw Exception("Prediction request failed: $e");
    }
  }

  /// ==========================
  /// 💓 Health Check with detailed response
  /// ==========================
  static Future<Map<String, dynamic>> checkServerHealth() async {
    try {
      print('🔍 Checking server health at $baseUrl/health');
      final uri = Uri.parse('$baseUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      print('🏥 Health check response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {
          'status': true,
          'data': _safeJsonDecode(response.body),
        };
      } else {
        return {
          'status': false,
          'error': 'Server responded with ${response.statusCode}',
        };
      }
    } on SocketException {
      return {
        'status': false,
        'error': 'Cannot reach server at $baseUrl',
      };
    } on TimeoutException {
      return {
        'status': false,
        'error': 'Health check timed out',
      };
    } catch (e) {
      return {
        'status': false,
        'error': 'Health check failed: $e',
      };
    }
  }

  /// ==========================
  /// 🧰 Helper - Safe JSON decode
  /// ==========================
  static dynamic _safeJsonDecode(String source) {
    try {
      return jsonDecode(source);
    } catch (_) {
      return {"error": source};
    }
  }
}
