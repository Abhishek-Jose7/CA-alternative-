import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ApiService {
  // Replace with your actual Cloud Run URL or local IP (10.0.2.2 for Android emulator)
  // For Web, 10.0.2.2 won't work. Use localhost or specific IP if running locally.
  // If backend is on 8000, and running web on same machine, localhost:8000 usually works for web
  // BUT: Flutter Web complicates localhost due to browser security (CORS) or container networking.
  // Assuming standard localhost for now, user might need to handle CORS on backend if this fails differently.
  static const String baseUrl = "http://127.0.0.1:8000"; 

  Future<Map<String, dynamic>> decodeNotice(XFile imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/notice/decode'));
    
    // Read bytes for web compatibility
    final bytes = await imageFile.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'file', 
      bytes, 
      filename: imageFile.name
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to decode notice: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> parseInvoice(XFile imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/invoice/parse'));
    
    final bytes = await imageFile.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'file', 
      bytes, 
      filename: imageFile.name
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to parse invoice: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> searchHSN(String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/hsn'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"query": query}),
    );
     if (response.statusCode == 200) return json.decode(response.body);
     throw Exception('HSN Search Failed');
  }

  Future<Map<String, dynamic>> chatWithAI(String message, {String language = 'en', String? userId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"message": message, "language": language, "user_id": userId}),
    );
     if (response.statusCode == 200) return json.decode(response.body);
     throw Exception('Chat Failed');
  }
}
