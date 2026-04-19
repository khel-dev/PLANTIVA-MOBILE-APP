import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClassifierService {
  // Para sa emulator — 10.0.2.2 ang localhost ng PC
  // Para sa actual phone — gamitin ang IP ng PC mo: 192.168.1.14
  final String _apiUrl = 'http://10.0.2.2:5000/predict';

  Future<void> loadModel() async {
    // Wala nang kailangan — API ang bahala
    print('API-based classifier ready!');
  }

  Future<Map<String, String>> classify(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(_apiUrl),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      if (data['success'] == true) {
        return {
          'label': data['label'],
          'confidence': data['confidence'],
          'raw_label': data['raw_label'],
        };
      } else {
        return {
          'label': 'Error',
          'confidence': '0%',
          'raw_label': data['error'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      print('Error calling API: $e');
      return {
        'label': 'Cannot connect to API',
        'confidence': '0%',
        'raw_label': 'Error: $e',
      };
    }
  }

  void close() {
    // Nothing to close
  }
}