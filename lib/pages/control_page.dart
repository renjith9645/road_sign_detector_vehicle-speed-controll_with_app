import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class ControlPage extends StatefulWidget {
  final String ip;

  const ControlPage({super.key, required this.ip});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  String direction = "STOP";
String sign = "-";
int speed = 0;double zoomLevel = 1.0;

bool connected = false;

Timer? timer;

late final WebViewController webController;
 @override
void initState() {
  super.initState();

  webController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.black)
    ..loadRequest(
      Uri.parse(
        "http://${widget.ip}/video_feed",
      ),
    );

  getStatus();

  timer = Timer.periodic(
    const Duration(milliseconds: 500),
    (_) {
      getStatus();
    },
  );
}Future<void> zoomIn() async {
  zoomLevel += 0.2;

  await webController.runJavaScript(
    """
    document.body.style.zoom = '$zoomLevel';
    """,
  );
}Future<void> zoomOut() async {
  if (zoomLevel > 0.4) {
    zoomLevel -= 0.2;

    await webController.runJavaScript(
      """
      document.body.style.zoom = '$zoomLevel';
      """,
    );
  }
}
  Future<void> getStatus() async {
    try {
      final response = await http.get(Uri.parse("http://${widget.ip}/status"));

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        connected = true;

        direction = data["direction"] ?? "STOP";
        speed = data["speed"] ?? 0;

        if (data["detected_signs"] != null &&
            data["detected_signs"] is List &&
            data["detected_signs"].isNotEmpty) {
          sign = data["detected_signs"][0].toString();
        } else {
          sign = "-";
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        connected = false;
      });

      debugPrint(e.toString());
    }
  }

  Future<void> sendCommand(String cmd) async {
    try {
      await http.get(Uri.parse("http://${widget.ip}/control/$cmd"));

      await getStatus();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
Future<void> refreshDashboard() async {
  await getStatus();

  await webController.reload();

  if (!mounted) return ;

    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(const SnackBar(content: Text("Dashboard Refreshed")));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget statusCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF101B3A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.cyanAccent),
          boxShadow: const [BoxShadow(color: Colors.cyanAccent, blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.cyanAccent),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget controlButton(IconData icon, String cmd) {
    return SizedBox(
      width: 90,
      height: 90,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5FF),
          foregroundColor: Colors.black,
          shape: const CircleBorder(),
          elevation: 20,
        ),
        onPressed: () => sendCommand(cmd),
        child: Icon(icon, size: 45),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: const Icon(Icons.refresh),
      //     onPressed: refreshDashboard,
      //   ),
      //   title: const Text(
      //     "ROAD SIGN DETECTOR",
      //     style: TextStyle(letterSpacing: 2),
      //   ),
      // ),
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.refresh),
    onPressed: refreshDashboard,
  ),
  title: const Text(
    "ROAD SIGN DETECTOR",
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.zoom_out),
      onPressed: zoomOut,
    ),
    IconButton(
      icon: const Icon(Icons.zoom_in),
      onPressed: zoomIn,
    ),
  ],
),
      body: RefreshIndicator(
        onRefresh: refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Container(
  height: 230,
  width: double.infinity,
  margin: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.cyanAccent,
      width: 2,
    ),
  ),
  clipBehavior: Clip.hardEdge,
  child: WebViewWidget(
    controller: webController,
  ),
),

              // Container(height: 30, width: double.infinity  ,
              //   margin: const EdgeInsets.symmetric(horizontal: 12),
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(
              //     color: connected ? Colors.green : Colors.red,
              //     borderRadius: BorderRadius.circular(15),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Icon(
              //         connected ? Icons.wifi : Icons.wifi_off,
              //         color: Colors.white,
              //       ),
              //       const SizedBox(width: 10),
              //       Text(
              //         connected ? "CONNECTED" : "DISCONNECTED",
              //         style: const TextStyle(
              //           color: Colors.white,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    statusCard("Direction", direction, Icons.navigation),
                    statusCard("Speed", speed.toString(), Icons.speed),
                    statusCard("Sign", sign, Icons.traffic),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              controlButton(Icons.keyboard_arrow_up, "F"),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  controlButton(Icons.keyboard_arrow_left, "L"),
                  const SizedBox(width: 20),
                  controlButton(Icons.stop, "STOP"),
                  const SizedBox(width: 20),
                  controlButton(Icons.keyboard_arrow_right, "R"),
                ],
              ),

              const SizedBox(height: 15),

              controlButton(Icons.keyboard_arrow_down, "B"),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
