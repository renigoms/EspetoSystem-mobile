import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:espetosystem/app/data/services/base_data_source.dart';

class SupabaseService implements IBaseRemoteDataSource {
  final SupabaseClient client;

  SupabaseService(this.client);

  @override
  Future<List<Map<String, dynamic>>> fetchAll(String table) async {
    final response = await client.from(table).select();
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWithFilter(
    String table,
    String column,
    dynamic value,
  ) async {
    final response = await client.from(table).select().eq(column, value);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWhereIn(
    String table,
    String column,
    List<dynamic> values,
  ) async {
    final response = await client.from(table).select().inFilter(column, values);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> fetchById(String table, String id) async {
    final response = await client.from(table).select().eq('id', id).single();
    return response;
  }

  @override
  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await client.from(table).upsert(data).select().single();
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<void> delete(String table, String id) async {
    await client.from(table).delete().eq('id', id);
  }
}
