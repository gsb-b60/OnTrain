import 'package:ontrain/data/object/pt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Ptrepository {
  final SupabaseClient _supabaseClient;

  Ptrepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<List<PT>> getPTsWithLimit(int limit) async {
    try {
      final response = await _supabaseClient
          .from('pt_profiles')
          .select('''
            *,
            profiles!inner (
              id,
              email,
              full_name,
              avatar_url,
              phone,
              is_verified
            )
          ''')
          .eq('status', 'active')
          .limit(limit);

      return response.map((pt) {
        final profile = pt['profiles'] as Map<String, dynamic>?;
        return PT.fromMap({
          ...pt,
          if (profile != null) ...profile,
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PT>> searchPTsByName(String query) async {
    try {
      final response = await _supabaseClient
          .from('pt_profiles')
          .select('''
            *,
            profiles!inner (
              id,
              email,
              full_name,
              avatar_url,
              phone,
              is_verified
            )
          ''')
          .eq('status', 'active')
          .ilike('headline', '%$query%')
          .limit(20);

      return response.map((pt) {
        final profile = pt['profiles'] as Map<String, dynamic>?;
        return PT.fromMap({
          ...pt,
          if (profile != null) ...profile,
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<PT?> getPTById(String id) async {
    try {
      final response = await _supabaseClient
          .from('pt_profiles')
          .select('''
            *,
            profiles!inner (
              id,
              email,
              full_name,
              avatar_url,
              phone,
              is_verified
            )
          ''')
          .eq('id', id)
          .single();

      final profile = response['profiles'] as Map<String, dynamic>?;
      return PT.fromMap({
        ...response,
        if (profile != null) ...profile,
      });
    } catch (e) {
      return null;
    }
  }
}