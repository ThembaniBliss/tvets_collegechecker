// ignore_for_file: use_key_in_widget_constructors, duplicate_ignore, sort_child_properties_last

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

  const MyApp({required this.supabaseClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TVET College Checker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CollegeCheckerScreen(supabaseClient: supabaseClient),
      debugShowCheckedModeBanner: false, // Removes the debug banner
    );
  }
}

class CollegeCheckerScreen extends StatefulWidget {
  final SupabaseClient supabaseClient;

  // ignore: use_key_in_widget_constructors
  const CollegeCheckerScreen({required this.supabaseClient});

  @override
  _CollegeCheckerScreenState createState() => _CollegeCheckerScreenState();
}

class _CollegeCheckerScreenState extends State<CollegeCheckerScreen> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';

  Future<void> checkCollege(String name) async {
    try {
      final response = await widget.supabaseClient
          .from('colleges')
          .select()
          .eq('name', name)
          .maybeSingle();

      if (response == null || response['name'] == null) {
        setState(() {
          _result = 'College not found.';
        });
      } else {
        final college = response as Map<String, dynamic>;
        setState(() {
          _result = 'College found: ${college['name']}';
        });
      }
    } catch (error) {
      setState(() {
        _result = 'Unexpected error: $error';
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
                border:
                    const OutlineInputBorder(), // Adds border to the TextField
                fillColor: Colors.blueGrey[50],
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => checkCollege(_controller.text),
              child: const Text('Check'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Text color
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _result,
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
