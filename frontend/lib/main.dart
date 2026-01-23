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

  //Controllers for obtaining user input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  
  Future<void> fetchFromBackend() async {
    final name = _nameController.text;
    final tag = _tagController.text;

    //Safety check for empty inputs
    if(name.isEmpty || tag.isEmpty) {
      setState(() {
        _message = "Please enter both Username and Tagline";
      });
      return;
    }

    //The URL destination (takes game name and tagline)
    final url = Uri.parse('http://127.0.0.1:8000/player/$name/$tag');

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
        // Added Padding so the boxes aren't stuck to the edges
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_message, textAlign: TextAlign.center), 
              const SizedBox(height: 20),
              
              // CHANGE 4: Add the actual Input Boxes (TextFields)
              TextField(
                controller: _nameController, // Connects box to variable
                decoration: const InputDecoration(
                  labelText: "Game Name (e.g. Doublelift)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _tagController, // Connects box to variable
                decoration: const InputDecoration(
                  labelText: "Tag Line (e.g. NA1)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: fetchFromBackend, 
                child: const Text("Ping Server"),
            ),
          ],
        ),
      ),
    ));
  }
}