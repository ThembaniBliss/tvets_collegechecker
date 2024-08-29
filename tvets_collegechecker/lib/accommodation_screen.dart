import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

class AccommodationScreen extends StatefulWidget {
  final SupabaseClient supabaseClient;
  const AccommodationScreen({super.key, required this.supabaseClient});

  @override
  _AccommodationScreenState createState() => _AccommodationScreenState();
}

class _AccommodationScreenState extends State<AccommodationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _accommodationResults = [];
  String _result = '';
  String _commentResult = '';

  Future<void> searchAccommodations(String name) async {
    try {
      var response = await widget.supabaseClient
          .from('accommodationproviders')
          .select('id, name, location, website, image_url') // include image_url
          .ilike('name', '%$name%');

      if (response.isNotEmpty) {
        setState(() {
          _accommodationResults = List<Map<String, dynamic>>.from(response);
          _result = '';
        });
      } else {
        setState(() {
          _accommodationResults = [];
          _result = 'No accommodation providers found.';
        });
      }
    } catch (error) {
      setState(() {
        _accommodationResults = [];
        _result = 'Unexpected error: $error';
      });
    }
  }

  Future<void> submitComment(String comment, int accommodationId) async {
    try {
      final response =
          await widget.supabaseClient.from('accommodation_comments').insert({
        'accommodation_id': accommodationId,
        'comment': comment,
      });

      if (response.isNotEmpty) {
        setState(() {
          _commentResult = 'Comment submitted successfully!';
          _commentController.clear();
        });
      } else {
        setState(() {
          _commentResult = 'Failed to submit comment.';
        });
      }
    } catch (error) {
      setState(() {
        _commentResult = 'Unexpected error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Accommodation Listings'),
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
                controller: _searchController,
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
                onPressed: () => searchAccommodations(_searchController.text),
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
                child: _accommodationResults.isNotEmpty
                    ? ListView.builder(
                        itemCount: _accommodationResults.length,
                        itemBuilder: (context, index) {
                          final accommodation = _accommodationResults[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    accommodation['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Location: ${accommodation['location']}\n'
                                    'Website: ${accommodation['website']}',
                                    style: const TextStyle(
                                        color: Colors.blueAccent),
                                  ),
                                  isThreeLine: true,
                                  leading: accommodation['image_url'] != null
                                      ? Image.network(
                                          accommodation['image_url'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image_not_supported),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: _commentController,
                                        decoration: const InputDecoration(
                                          labelText: 'Leave a comment',
                                          border: OutlineInputBorder(),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () => submitComment(
                                            _commentController.text,
                                            accommodation['id']),
                                        child: const Text('Submit Comment'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.blueAccent,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          textStyle:
                                              const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      if (_commentResult.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            _commentResult,
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
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
