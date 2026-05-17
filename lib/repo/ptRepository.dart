import 'package:ontrain/data/object/pt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Ptrepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;


  Future<List<PT>> getPTsWithLimit(int limit) async {
    print("im here");
    try {
      final response = await _supabaseClient
          .from("PT")
          .select()
          .limit(limit);
        
      print("find pt: $response");
      return response.map((pt) => PT.fromMap(pt)).toList();
    } catch (e) {
      print("Error fetching PTs by specialty: $e");
      return [];
    }
  }
}