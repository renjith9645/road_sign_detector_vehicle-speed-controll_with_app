import 'dart:convert';
import 'package:http/http.dart' as http;

class RobotService {
  final String ip;

  RobotService(this.ip);

  Future<Map<String, dynamic>> getStatus() async {
    final response = await http.get(Uri.parse("http://$ip/status"));

    return jsonDecode(response.body);
  }

  Future<void> sendCommand(String cmd) async {
    await http.get(Uri.parse("http://$ip/control/$cmd"));
  }
}
