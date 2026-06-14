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
        final List<Map<String, dynamic>> data = await remoteDataSource
            .fetchWithFilter(tableName, 'user_id', userId);

        // Update cache with fresh data from remote
        await localDataSource.save(userCacheKey, data);

        return data.map((e) => fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error loading $tableName from remote for user $userId: $e');
        // Fallback to cache on remote error
        return getCachedList(userCacheKey);
      }
    } else {
      // Offline: return cached data
      return getCachedList(userCacheKey);
    }
  }

  Future<T?> saveForUser(T model, String userId) async {
    final userCacheKey = '${cacheKey}_$userId';
    final syncQueueKey = 'sync_queue_${tableName}_$userId';
    final Map<String, dynamic> data = toJson(model);

    if (!data.containsKey('user_id') &&
        !tableName.contains('_') &&
        tableName != 'payment' &&
        tableName != 'item' &&
        tableName != 'address') {
      data['user_id'] = userId;
    }

    // 1. Local-first: Sempre atualiza o cache local
    await upsertCachedUserModel(userCacheKey, data);

    if (await networkInfo.isConnected) {
      try {
        final savedData = await remoteDataSource.upsert(tableName, data);
        final savedMap = savedData is Map<String, dynamic> ? savedData : data;
        await upsertCachedUserModel(userCacheKey, savedMap);
        return fromJson(savedMap);
      } catch (e) {
        debugPrint('Error saving $tableName to remote. Adding to sync queue.');
        await _addToSyncQueue(syncQueueKey, data);
        return fromJson(data);
      }
    } else {
      // Offline: Adiciona à fila de sincronização persistente
      await _addToSyncQueue(syncQueueKey, data);
      return fromJson(data);
    }
  }

  Future<void> _addToSyncQueue(String key, Map<String, dynamic> data) async {
    final queue = localDataSource.get(key) as List? ?? [];
    final List<Map<String, dynamic>> updatedQueue = 
        queue.map((e) => Map<String, dynamic>.from(e)).toList();
    
    // Se não tiver ID, gera um temporário para rastreamento local
    if (data['id'] == null) {
      data['id'] = 'temp_${DateTime.now().millisecondsSinceEpoch}_${data.hashCode}';
    }

    final id = data['id'];
    final index = updatedQueue.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      updatedQueue[index] = data;
    } else {
      updatedQueue.add(data);
    }
    
    await localDataSource.save(key, updatedQueue);
  }

  Future<Map<String, String>> syncWithRemote(String userId) async {
    if (!await networkInfo.isConnected) return {};

    final syncQueueKey = 'sync_queue_${tableName}_$userId';
    final userCacheKey = '${cacheKey}_$userId';
    final queue = localDataSource.get(syncQueueKey) as List? ?? [];

    if (queue.isEmpty) return {};

    debugPrint('Syncing ${queue.length} pending items for $tableName...');
    
    final List<Map<String, dynamic>> remainingQueue = [];
    final Map<String, String> idMapping = {};

    for (var item in queue) {
      try {
        final data = Map<String, dynamic>.from(item);
        final String? tempId = data['id']?.toString().startsWith('temp_') == true ? data['id'] : null;
        
        // Se for um item novo (ID temporário), removemos o ID para o Supabase gerar um novo
        if (tempId != null) {
          data.remove('id');
        }

        final savedData = await remoteDataSource.upsert(tableName, data);
        final savedMap = savedData is Map<String, dynamic> ? savedData : data;
        
        if (tempId != null && savedMap['id'] != null) {
          idMapping[tempId] = savedMap['id'].toString();
          // Remove o item com ID temporário do cache local
          await removeFromCache(userCacheKey, tempId);
        }

        // Atualiza o cache local com o ID real do banco
        await upsertCachedUserModel(userCacheKey, savedMap);
      } catch (e) {
        debugPrint('Failed to sync item in $tableName: $e');
        remainingQueue.add(Map<String, dynamic>.from(item));
      }
    }

    // Atualiza a fila apenas com o que falhou
    await localDataSource.save(syncQueueKey, remainingQueue);
    return idMapping;
  }

  Future<void> removeFromCache(String key, String id) async {
    final cachedData = localDataSource.get(key);
    if (cachedData is List) {
      final list = cachedData.where((item) {
        if (item is Map) {
          return item['id'] != id;
        }
        return true;
      }).toList();
      await localDataSource.save(key, list);
    }
  }

  Future<void> upsertCachedUserModel(
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

  Future<List<T>> getCachedList(String key) async {
    final cachedData = localDataSource.get(key);
    if (cachedData != null && cachedData is List) {
      return cachedData
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<void> deleteById(String id, String userId) async {
    final userCacheKey = '${cacheKey}_$userId';

    // Remove from local cache
    final cachedData = localDataSource.get(userCacheKey);
    if (cachedData is List) {
      final list =
          cachedData.where((item) {
            if (item is Map) {
              return item['id'] != id;
            }
            return true;
          }).toList();
      await localDataSource.save(userCacheKey, list);
    }

    // Remove from remote
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.delete(tableName, id);
      } catch (e) {
        debugPrint('Error deleting from $tableName: $e');
      }
    }
  }
}
