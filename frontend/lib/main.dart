import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the tool to make internet requests

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const BackendTester(), //will default homepage to BackendTester below
    );
  }
}

//Data and displayed information will change | Stateful
class BackendTester extends StatefulWidget {
  const BackendTester({super.key});

  @override
  State<BackendTester> createState() => _BackendTesterState();
}

class _BackendTesterState extends State<BackendTester> {

  //String variable that will contain information from backend.
  String _message =   "No data yet";

  
  Future<void> fetchFromBackend() async {

    //The URL destination
    final url = Uri.parse('http://127.0.0.1:8000/');

    try {

      //Stores the URL's response
      final response = await http.get(url);

      //If successful, 
      if (response.statusCode == 200) {

        setState(() {
          _message = "Server says: ${response.body}";
        });
      }
      else {
        setState(() {
          _message = "Error: Server response ${response.statusCode}";
        });
      }
    }

    //If unable to connect to server, display connection failure.
    catch(e){
      setState(() {
        _message = "Connection Failed: $e";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Backend Connection Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The text widget displays whatever is currently in '_message'
            Text(_message, textAlign: TextAlign.center), 
            const SizedBox(height: 20),
            
            // The button that starts the 'fetchFromBackend' function
            ElevatedButton(
              onPressed: fetchFromBackend, 
              child: const Text("Ping Server"),
            ),
          ],
        ),
      ),
    );
  }
}