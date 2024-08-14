// ignore_for_file: sort_child_properties_las
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception("Supabase environment variables not found.");
  }
  SupabaseClient supabaseClient = SupabaseClient(supabaseUrl, supabaseAnonKey);
  print('Supabase Initialized with URL: $supabaseUrl');

  // Initialize Supabase with the necessary settings
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    //authFlowType: AuthFlowType.pkce, // Ensure PKCE flow is enabled for web
  );
  runApp(MyApp(supabaseClient: supabaseClient));
}

class MyApp extends StatelessWidget {
  final SupabaseClient supabaseClient;
  const MyApp({super.key, required this.supabaseClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College and Accomodation checker ',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(supabaseClient: supabaseClient),
      debugShowCheckedModeBanner: false,
    );
  }
}
