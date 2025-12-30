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

  Future<Map<String, dynamic>> decodeNotice(XFile imageFile, {String language = 'en'}) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/notice/decode?language=$language'));
    
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
     if (response.statusCode == 200) {
       // Fix: Explicitly decode as UTF-8 to prevent weird characters (mojibake)
       return json.decode(utf8.decode(response.bodyBytes));
     }
     throw Exception('Chat Failed');
  }

  Future<Map<String, dynamic>> chatWithImage(String message, XFile imageFile) async {
    // FIX: Endpoint was mismatching with backend. 
    // Backend defines: @router.post("/chat/vision") -> /api/chat/vision (because of prefix in main.py)
    // BUT we need to check if main.py adds a prefix. Usually it's just /chat/vision if included directly or with prefix.
    // Let's assume standard /api prefix from main.py or just check the router. 
    // Wait, the previous code had /api/chat/vision. 
    // Let's check main.py to be sure about the prefix.
    // For now, let's try to be consistent. 
    // If the error is 404, it's the path. If 500, it's the backend logic.
    // User said "image doesnt go into the chat". 
    // This implies the request might be failing.
    
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/chat/vision'));
    
    // Fix: 'message' should be a field, not in the body json for Multipart
    request.fields['message'] = message;
    
    // Fix: Read bytes for robust web/mobile support
    final bytes = await imageFile.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'file', 
      bytes, 
      filename: imageFile.name
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Fix: Explicitly decode UTF-8 here too
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      print("Error uploading image: ${response.body}"); // Debug log
      throw Exception('Failed to chat with image: ${response.statusCode}');
    }
  }
}

