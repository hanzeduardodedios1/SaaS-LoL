import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the tool to make internet requests
import 'dart:convert'; //Enables conversion of raw text into list

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

//This class primarily works with the backend.
class _BackendTesterState extends State<BackendTester> {

  //Storing a list of matches
  List<dynamic> _matches = [];
  String _statusMessage = "Enter a name to search: ";

  //Controllers for obtaining user input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  
  Future<void> fetchFromBackend() async {
    final name = _nameController.text;
    final tag = _tagController.text;

    //Safety check for empty inputs
    if(name.isEmpty || tag.isEmpty) {
      setState(() => _statusMessage = "Please enter both Username and Tag");
      return;
    }
    //Clears previous inputs
    setState(() {
      _matches = [];
      _statusMessage = "Loading...";
    });

    //The URL destination (takes game name and tagline)
    final url = Uri.parse('http://127.0.0.1:8000/player/$name/$tag');

    try {
      //Stores the URL's response
      final response = await http.get(url);
      

      //If successful, 
      if (response.statusCode == 200) {
        //Turns JSON string into an actual list
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _matches = data;
          _statusMessage = _matches.isEmpty ? "No ranked games found" : "";
        });
      }
      else {
        setState(() {
          _statusMessage = "Error: Server response ${response.statusCode}";
        });
      }
    }
    //If unable to connect to server, display connection failure.
      catch(e){
        setState(() {
          _statusMessage = "Connection Failed: $e";
      });
    }
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("League SaaS MVP")),
      body: Column(
        children: [
          // --- TOP SECTION: INPUTS ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Game Name (e.g. Doublelift)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    labelText: "Tag Line (e.g. NA1)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: fetchFromBackend,
                    child: const Text("Ping Server"),
                  ),
                ),
                // Show status message if there is an error or loading text
                if (_statusMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(_statusMessage, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),

          // --- BOTTOM SECTION: THE LIST ---
          Expanded(
            child: ListView.builder(
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];
                final isWin = match['win'] == true;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isWin ? Colors.blue[50] : Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ROW 1: Champion Name and Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              match['champion'] ?? "Unknown",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              "${match['kills']} / ${match['deaths']} / ${match['assists']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  // Make KDA green if they did well (Kills > Deaths), else grey
                                  color: (match['kills'] ?? 0) > (match['deaths'] ?? 0) 
                                      ? Colors.green[700] 
                                      : Colors.grey[800],
                                  )
                            ),
                            Text(
                              isWin ? "VICTORY" : "DEFEAT",
                              style: TextStyle(
                                color: isWin ? Colors.blue : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Gold: ${match['gold_earned']}  |  CS: ${match['cs']}  |  Dmg: ${match['total_damage']}",
                              style: TextStyle(color: Colors.grey[700], fontSize: 12),
                            ),

                            const SizedBox(height: 10,)
                          ],
                        ),
                        Text("Gold: ${match['gold_earned']} | CS: ${match['cs']}"),
                        const SizedBox(height: 10),
                        
                        // ROW 2: Item Images
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: (match['Items'] as List<dynamic>).map<Widget>((itemUrl) {
                              if (itemUrl == null) return const SizedBox(); // Skip empty items
                              return Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Image.network(
                                  itemUrl, 
                                  width: 30, 
                                  height: 30,
                                  errorBuilder: (c,e,s) => const Icon(Icons.broken_image, size: 30),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}