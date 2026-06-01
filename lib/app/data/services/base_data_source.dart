abstract class IBaseRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchAll(String table);
  Future<List<Map<String, dynamic>>> fetchWithFilter(
    String table,
    String column,
    dynamic value,
  );
  Future<List<Map<String, dynamic>>> fetchWhereIn(
    String table,
    String column,
    List<dynamic> values,
  );
  Future<Map<String, dynamic>> fetchById(String table, String id);
  Future<Map<String, dynamic>> upsert(String table, Map<String, dynamic> data);
  Future<void> delete(String table, String id);
}

abstract class IBaseLocalDataSource {
  Future<void> save(String key, dynamic value);
  dynamic get(String key);
  Future<void> remove(String key);
  Future<void> clear();
}
