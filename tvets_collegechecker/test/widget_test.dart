import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:supabase/supabase.dart';
import 'package:tvets_collegechecker/main.dart'; // Ensure this matches your project structure

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  testWidgets('MyApp loads with initial UI', (WidgetTester tester) async {
    final mockSupabaseClient = MockSupabaseClient();

    // Wrap MyApp in a provider that provides the mock SupabaseClient
    await tester.pumpWidget(
      Provider<SupabaseClient>.value(
        value: mockSupabaseClient,
        child: MaterialApp(
          home: MyApp(
              supabaseClient:
                  mockSupabaseClient), // Ensure MyApp is a widget that accepts the context
        ),
      ),
    );

    // Verify the app loads a widget that includes the text 'Enter South African TVET college name'
    expect(find.text('Enter South African TVET college name'), findsOneWidget);
    // Assuming you have a button to check college
    expect(find.text('Check'), findsOneWidget);
  });
}
