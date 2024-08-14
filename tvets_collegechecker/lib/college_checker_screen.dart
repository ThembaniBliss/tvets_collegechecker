import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

class CollegeCheckerScreen extends StatefulWidget {
  final SupabaseClient supabaseClient;
  const CollegeCheckerScreen({super.key, required this.supabaseClient});
  @override
  _CollegeCheckerScreenState createState() => _CollegeCheckerScreenState();
}

class _CollegeCheckerScreenState extends State<CollegeCheckerScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  String _result = ''; // Correctly defining _result here for UI feedback

  Future<void> searchColleges(String name) async {
    try {
      var response = await widget.supabaseClient
          .from('colleges')
          .select('name, location, website, contact')
          .ilike('name', '%$name%');
      //.ilike('name', '%$name%');
      //Debugging print statements
      print('Response: $response');

      if (response.isNotEmpty) {
        setState(() {
          _results = List<Map<String, dynamic>>.from(response);
          _result = ''; // Clear any previous error message
        });
      } else {
        setState(() {
          _results = [];
          _result =
              'colleges  not found.'; // Informative message when no data is found
        });
      }
    } catch (error) {
      setState(() {
        _results = [];
        _result =
            'Unexpected error: $error'; // Error message when there is an exception
      });
      print('Error: $error');
    }
  }

  Future<void> checkConnection() async {
    try {
      var response =
          await widget.supabaseClient.from('colleges').select().limit(1);
      print('Connection check response: $response');
    } catch (error) {
      print('Connection check error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    checkConnection(); // Call the method to check connection on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TVET College Checker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter South African TVET college name',
                border: const OutlineInputBorder(),
                fillColor: Colors.blueGrey[50],
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => searchColleges(_controller.text),
              // ignore: sort_child_properties_last
              child: const Text('Search'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final college = _results[index];
                  return ListTile(
                    title: Text(college['name']),
                    subtitle: Text(
                        'Location: ${college['location']}\nWebsite: ${college['website']}\nContact: ${college['contact']}'),
                  );
                },
              ),
            ),
            Text(
              _result, // Display the result message here
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
