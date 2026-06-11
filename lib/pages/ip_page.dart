import 'package:flutter/material.dart';
import 'control_page.dart';

class IpPage extends StatefulWidget {
  const IpPage({super.key});

  @override
  State<IpPage> createState() => _IpPageState();
}

class _IpPageState extends State<IpPage> {
  final TextEditingController ipController = TextEditingController(
    text: "192.168.1.36:5000",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ROAD SIGN DETECTOR",
          style: TextStyle(letterSpacing: 2),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.smart_toy,
                    color: Colors.cyanAccent,
                    size: 120,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "ROAD SIGN DETECTOR",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                    ),
                  ),

                  const SizedBox(height: 25),

                  TextField(
                    controller: ipController,
                    decoration: InputDecoration(
                      labelText: "Raspberry Pi IP",
                      prefixIcon: const Icon(Icons.wifi),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.rocket_launch),
                      label: const Text("CONNECT"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ControlPage(ip: ipController.text.trim()),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
