import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase/supabase.dart';
import 'package:tvets_collegechecker/main.dart';

// Creating a mock class for SupabaseClient using Mockito
class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  // Create a mock instance of SupabaseClient
  final mockSupabaseClient = MockSupabaseClient();

  testWidgets('MyApp loads with initial UI', (WidgetTester tester) async {
    // Build our app and trigger a frame with the mock SupabaseClient.
    await tester.pumpWidget(MyApp(supabaseClient: mockSupabaseClient));

    // Verify the app loads a widget that includes the text 'Enter college name'
    expect(find.text('Enter college name'), findsOneWidget);

    // Assuming you have a button to check college
    expect(find.text('Check'), findsOneWidget);
  });
}
