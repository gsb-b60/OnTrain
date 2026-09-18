import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postgrest/postgrest.dart';

@GenerateNiceMocks([
  MockSpec<SupabaseClient>(),
  MockSpec<PostgrestQueryBuilder>(),
  MockSpec<PostgrestFilterBuilder>(),
  MockSpec<PostgrestTransformBuilder>(),
  MockSpec<RealtimeChannel>(),
  MockSpec<User>(),
  MockSpec<Session>(),
])
void main() {
  // This file exists to trigger mock generation via build_runner.
  // The actual mocks are generated in mock_supabase.mocks.dart
}