import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Replace with your actual Cloud Run URL or local IP (10.0.2.2 for Android emulator)
  static const String baseUrl = "http://10.0.2.2:8000"; 

  Future<Map<String, dynamic>> decodeNotice(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/notice/decode'));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to decode notice: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> parseInvoice(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/invoice/parse'));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to parse invoice: ${response.body}');
    }
  }
}
