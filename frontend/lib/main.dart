import 'package:flutter/material.dart';
import 'api_service.dart'; // <--- Connects to your new logic file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MatchHistoryScreen(),
    );
  }
}

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  // 1. Initialize the Service
  final ApiService _apiService = ApiService();

  // 2. UI State Variables
  List<dynamic> _matches = [];
  bool _isLoading = false;
  String _errorMessage = "";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  // 3. The Clean Function
  void _searchPlayer() async {
    // Combine inputs | Username and Tagline
    String fullId = "${_nameController.text}#${_tagController.text}";

    setState(() {
      _isLoading = true;
      _errorMessage = "";
      _matches = [];
    });

    try {
      // ASK THE SERVICE FOR DATA
      final data = await _apiService.fetchPlayerMatches(fullId);

      setState(() {
        _matches = data;
        _isLoading = false;
        if (_matches.isEmpty) _errorMessage = "No ranked games found.";
      });
    } catch (e) {
      setState(() {
        // Clean up the error message for the user
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("League SaaS MVP")),
      body: Column(
        children: [
          // --- SECTION 1: SEARCH INPUTS ---
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
                    onPressed: _isLoading ? null : _searchPlayer, // Disable if loading
                    child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Ping Server"),
                  ),
                ),
                // Show Error Message if exists
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),

          // --- SECTION 2: THE LIST ---
          Expanded(
            child: ListView.builder(
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];
                final isWin = match['win'] == true;
                final kdaColor = (match['kills'] ?? 0) > (match['deaths'] ?? 0) 
                    ? Colors.green[700] 
                    : Colors.grey[800];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isWin ? Colors.blue[50] : Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ROW 1: Champion & Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              match['champion'] ?? "Unknown",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              "${match['kills']} / ${match['deaths']} / ${match['assists']}",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kdaColor),
                            ),
                          ],
                        ),
                        // Win/Loss Label
                        Text(
                          isWin ? "VICTORY" : "DEFEAT",
                          style: TextStyle(
                            color: isWin ? Colors.blue : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Stats Row
                        Text(
                          "Gold: ${match['gold_earned']}  |  CS: ${match['cs']}  |  Dmg: ${match['total_damage']}",
                          style: TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                        const SizedBox(height: 10),

                        // ROW 2: Item Images
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: (match['Items'] as List<dynamic>).map<Widget>((itemUrl) {
                              if (itemUrl == null) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Image.network(
                                  itemUrl,
                                  width: 30,
                                  height: 30,
                                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 30),
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