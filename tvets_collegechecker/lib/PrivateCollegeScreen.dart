import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

class PrivateCollegeScreen extends StatefulWidget {
  final SupabaseClient supabaseClient;
  const PrivateCollegeScreen({super.key, required this.supabaseClient});

  @override
  _PrivateCollegeScreenState createState() => _PrivateCollegeScreenState();
}

class _PrivateCollegeScreenState extends State<PrivateCollegeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  String _result = '';

  Future<void> searchPrivateColleges(String name) async {
    try {
      var response = await widget.supabaseClient
          .from('private_colleges')
          .select('name, location, website, contact')
          .ilike('name', '%$name%');

      if (response.isNotEmpty) {
        setState(() {
          _results = List<Map<String, dynamic>>.from(response);
          _result = '';
        });
      } else {
        setState(() {
          _results = [];
          _result = 'No private colleges found matching your search.';
        });
      }
    } catch (error) {
      setState(() {
        _results = [];
        _result = 'Unexpected error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent,
        title: const Text('Private College Checker'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.white, Colors.orangeAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Please enter a Private College name to search:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Enter Private College name',
                  labelStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(),
                  fillColor: Colors.white70,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.purpleAccent, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => searchPrivateColleges(_searchController.text),
                child: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.purpleAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _results.isNotEmpty
                    ? ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final college = _results[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              title: Text(
                                college['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                              subtitle: Text(
                                'Location: ${college['location']}\nWebsite: ${college['website']}\nContact: ${college['contact']}',
                                style: const TextStyle(color: Colors.black87),
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          _result,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
