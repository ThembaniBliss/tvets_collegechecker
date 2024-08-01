// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase/supabase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception("Supabase environment variables not found.");
  }
  SupabaseClient supabaseClient = SupabaseClient(supabaseUrl, supabaseAnonKey);
  runApp(MyApp(supabaseClient: supabaseClient));
}

class MyApp extends StatelessWidget {
  final SupabaseClient supabaseClient;
  const MyApp({super.key, required this.supabaseClient});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TVET College Checker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CollegeCheckerScreen(supabaseClient: supabaseClient),
      debugShowCheckedModeBanner: false,
    );
  }
}

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
          .select(
              '*') // Select all columns or specify like 'name, location, website, contact'
          .ilike('name', '%$name%') // Case-insensitive partial match
          .execute(); // This should correctly fetch the data

      if (response.error == null &&
          response.data != null &&
          response.data.isNotEmpty) {
        setState(() {
          _results = List<Map<String, dynamic>>.from(response.data);
          _result = ''; // Clear any previous error message
        });
      } else {
        setState(() {
          _results = [];
          _result =
              'No colleges found matching your criteria.'; // Informative message when no data is found
        });
      }
    } catch (error) {
      setState(() {
        _results = [];
        _result =
            'Unexpected error: $error'; // Error message when there is an exception
      });
    }
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
