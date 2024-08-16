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
              'No colleges found matching your search.'; // Informative message when no data is found
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
        backgroundColor: Colors.blueAccent,
        title: const Text('TVET College Checker'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.white, Colors.greenAccent],
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
                'Please enter a TVET College name to search:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Enter South African TVET college name',
                  labelStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(),
                  fillColor: Colors.white70,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    // ignore: unnecessary_const
                    borderSide:
                        // ignore: unnecessary_const
                        const BorderSide(color: Colors.blueAccent, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => searchColleges(_controller.text),
                child: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
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
                                  color: Colors.blueAccent,
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
