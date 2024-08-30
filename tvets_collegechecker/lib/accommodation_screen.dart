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
          .select('id, name, location, website, image_url')
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
        'created_at': DateTime.now().toIso8601String(), // Add timestamp
      });

      if (response.error != null) {
        setState(() {
          _commentResult =
              'Failed to submit comment: ${response.error!.message}';
        });
      } else {
        setState(() {
          _commentResult = 'Comment submitted successfully!';
          _commentController.clear();
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
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
                decoration: InputDecoration(
                  labelText: 'Enter accommodation provider name',
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.greenAccent, width: 2.0),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: (_accommodationResults != null &&
                        _accommodationResults.isNotEmpty)
                    ? ListView.builder(
                        itemCount: _accommodationResults.length,
                        itemBuilder: (context, index) {
                          final accommodation = _accommodationResults[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: accommodation['image_url'] != null
                                        ? Image.network(
                                            accommodation['image_url'],
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 150,
                                            height: 150,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                              size: 60,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          accommodation['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.greenAccent,
                                            fontSize: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Location: ${accommodation['location']}',
                                          style: const TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Website: ${accommodation['website']}',
                                          style: const TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
              const SizedBox(height: 20),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Leave a comment',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_accommodationResults != null &&
                      _accommodationResults.isNotEmpty) {
                    submitComment(
                      _commentController.text,
                      _accommodationResults.first['id'],
                    );
                  }
                },
                child: const Text('Submit Comment'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              if (_commentResult.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
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
      ),
    );
  }
}
