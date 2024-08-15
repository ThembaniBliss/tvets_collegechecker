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
          _result = 'Accommodation providers not found.';
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
        title: const Text('Accommodation Providers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter accommodation provider name',
                border: const OutlineInputBorder(),
                fillColor: Colors.blueGrey[50],
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => searchAccommodations(_controller.text),
              // ignore: sort_child_properties_last
              child: const Text('Search'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final accommodation = _results[index];
                  return ListTile(
                    title: Text(accommodation['name']),
                    subtitle: Text(
                        'Location: ${accommodation['location']}\nAddress: ${accommodation['address']}\nContact: ${accommodation['contactNumbers']}\nEmail: ${accommodation['email']}\nWebsite: ${accommodation['website']}\nDistance from Hatfield: ${accommodation['distanceFromHatfield']} km'),
                  );
                },
              ),
            ),
            Text(
              _result,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
