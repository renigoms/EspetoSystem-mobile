import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client;

  SupabaseService(this.client);

  // Exemplo genérico de busca
  Future<List<Map<String, dynamic>>> fetchAll(String table) async {
    final response = await client.from(table).select();
    return List<Map<String, dynamic>>.from(response);
  }

  // Exemplo genérico de inserção/update
  Future<Map<String, dynamic>> upsert(String table, Map<String, dynamic> data) async {
    final response = await client.from(table).upsert(data).select().single();
    return response;
  }
}
