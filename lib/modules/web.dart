import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON parsing

// maybe convert to async
// POST request
Future<http.Response> postRequest(
    String url, Map<String, dynamic> body, Map<String, String>? headers) async {
  if (headers == null) {
    headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }
  return await http.post(Uri.parse(url),
      body: jsonEncode(body), headers: headers);
}

// GET request
Future<http.Response> getRequest(
    String url, Map<String, String>? headers) async {
  if (headers == null) {
    headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }
  return await http.get(Uri.parse(url), headers: headers);
}

// https://docs.flutter.dev/cookbook/networking/send-data