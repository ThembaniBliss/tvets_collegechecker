import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

import 'accommodation_screen.dart';
import 'college_checker_screen.dart';

class HomePage extends StatelessWidget {
  final SupabaseClient supabaseClient;
  const HomePage({super.key, required this.supabaseClient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CollegeCheckerScreen(supabaseClient: supabaseClient),
                  ),
                );
              },
              // ignore: sort_child_properties_last
              child: const Text('TVET College Checker'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AccommodationScreen(supabaseClient: supabaseClient),
                  ),
                );
              },
              // ignore: sort_child_properties_last
              child: const Text('Accommodation Providers'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
