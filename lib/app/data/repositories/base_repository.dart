import 'package:flutter/foundation.dart';
import 'package:espetosystem/app/data/services/base_data_source.dart';
import 'package:espetosystem/app/data/services/network_info.dart';

abstract class BaseRepository<T> {
  final IBaseRemoteDataSource remoteDataSource;
  final IBaseLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final String tableName;
  final String cacheKey;

  BaseRepository({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.tableName,
    required this.cacheKey,
  });

  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T model);

  Future<List<T>> getAllForUser(String userId) async {
    final userCacheKey = '${cacheKey}_$userId';
    
    if (await networkInfo.isConnected) {
      try {
        final List<Map<String, dynamic>> data = await remoteDataSource.fetchWithFilter(tableName, 'user_id', userId);
        
        // Update cache with fresh data from remote
        await localDataSource.save(userCacheKey, data);
        
        return data.map((e) => fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error loading $tableName from remote for user $userId: $e');
        // Fallback to cache on remote error
        return _getCachedList(userCacheKey);
      }
    } else {
      // Offline: return cached data
      return _getCachedList(userCacheKey);
    }
  }

  Future<T?> saveForUser(T model, String userId) async {
    final userCacheKey = '${cacheKey}_$userId';
    final Map<String, dynamic> data = toJson(model);
    data['user_id'] = userId;

    Future<T> _cacheAndReturnModel() async {
      await _upsertCachedUserModel(userCacheKey, data);
      return fromJson(data);
    }

    if (await networkInfo.isConnected) {
      try {
        final savedData = await remoteDataSource.upsert(tableName, data);
        final savedMap = savedData is Map<String, dynamic> ? savedData : data;
        await _upsertCachedUserModel(userCacheKey, savedMap);
        return fromJson(savedMap);
      } catch (e) {
        debugPrint('Error saving $tableName for user $userId: $e');
        rethrow;
      }
    } else {
      return _cacheAndReturnModel();
    }
  }

  Future<void> _upsertCachedUserModel(
    String key,
    Map<String, dynamic> data,
  ) async {
    final cachedData = localDataSource.get(key);
    final List<Map<String, dynamic>> list = <Map<String, dynamic>>[];

    if (cachedData is List) {
      for (final item in cachedData) {
        if (item is Map) {
          list.add(Map<String, dynamic>.from(item));
        }
      }
    }

    final dynamic id = data['id'];
    if (id != null) {
      final existingIndex = list.indexWhere((item) => item['id'] == id);
      if (existingIndex != -1) {
        list[existingIndex] = data;
      } else {
        list.add(data);
      }
    } else {
      list.add(data);
    }

    await localDataSource.save(key, list);
  }

  Future<List<T>> _getCachedList(String key) async {
    final cachedData = localDataSource.get(key);
    if (cachedData != null && cachedData is List) {
      return cachedData
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }
}
