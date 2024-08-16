import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

class AccommodationScreen extends StatefulWidget {
  final SupabaseClient supabaseClient;
  const AccommodationScreen({super.key, required this.supabaseClient});

  @override
  _AccommodationScreenState createState() => _AccommodationScreenState();
}

class _AccommodationScreenState extends State<AccommodationScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  String _result = '';

  Future<void> searchAccommodations(String name) async {
    try {
      var response = await widget.supabaseClient
          .from('accommodationproviders')
          .select(
              'name, location, address, contactnumbers, email, website, distancefromhatfield')
          .ilike('name', '%$name%');
      print('Response: $response');

      if (response.isNotEmpty) {
        setState(() {
          _results = List<Map<String, dynamic>>.from(response);
          _result = '';
        });
      } else {
        setState(() {
          _results = [];
          _result = 'No accommodation providers found.';
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
        backgroundColor: Colors.blue,
        title: const Text('Accommodation Providers'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.white, Colors.blueAccent],
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
                'Please enter an accommodation provider name to search:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Enter accommodation provider name',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.greenAccent, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => searchAccommodations(_controller.text),
                child: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
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
                          final accommodation = _results[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              title: Text(
                                accommodation['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              subtitle: Text(
                                'Location: ${accommodation['location']}\n'
                                'Address: ${accommodation['address']}\n'
                                'Contact: ${accommodation['contactnumbers']}\n'
                                'Email: ${accommodation['email']}\n'
                                'Website: ${accommodation['website']}\n'
                                'Distance from Hatfield: ${accommodation['distancefromhatfield']} km',
                                style:
                                    const TextStyle(color: Colors.blueAccent),
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
