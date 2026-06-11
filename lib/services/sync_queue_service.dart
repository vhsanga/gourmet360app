import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Gourmet360/core/constants/api_constants.dart';

class _QueuedRequest {
  final String id;
  final String path;
  final Map<String, dynamic> params;
  final String token;
  final DateTime enqueuedAt;
  int retries;

  _QueuedRequest({
    required this.id,
    required this.path,
    required this.params,
    required this.token,
    required this.enqueuedAt,
    this.retries = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'path': path,
    'params': params,
    'token': token,
    'enqueuedAt': enqueuedAt.toIso8601String(),
    'retries': retries,
  };

  factory _QueuedRequest.fromMap(Map<String, dynamic> map) => _QueuedRequest(
    id: map['id'] as String,
    path: map['path'] as String,
    params: Map<String, dynamic>.from(map['params'] as Map),
    token: map['token'] as String,
    enqueuedAt: DateTime.parse(map['enqueuedAt'] as String),
    retries: (map['retries'] as int?) ?? 0,
  );
}

/// Cola de POSTs offline con sincronización automática al volver la red.
/// Singleton: accesible desde HttpService sin necesitar BuildContext.
class SyncQueueService extends ChangeNotifier {
  static const String _queueKey = 'sync_queue';
  static const int _maxRetries = 5;

  static SyncQueueService? _instance;
  static SyncQueueService get instance {
    assert(_instance != null, 'SyncQueueService no fue inicializado.');
    return _instance!;
  }

  final List<_QueuedRequest> _queue = [];
  bool _isSyncing = false;
  String? _lastSyncMessage;

  int get pendingCount => _queue.length;
  bool get isSyncing => _isSyncing;
  String? get lastSyncMessage => _lastSyncMessage;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  SyncQueueService() {
    _instance = this;
    _loadQueue();
    _subscribeToConnectivity();
  }

  void _subscribeToConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online =
          results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
      if (online && _queue.isNotEmpty) {
        processQueue();
      }
    });
  }

  /// Agrega una solicitud POST a la cola offline.
  Future<void> enqueue(
    String path,
    Map<String, dynamic> params,
    String token,
  ) async {
    final item = _QueuedRequest(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      path: path,
      params: params,
      token: token,
      enqueuedAt: DateTime.now(),
    );
    _queue.add(item);
    await _saveQueue();
    notifyListeners();
  }

  /// Procesa la cola enviando cada solicitud pendiente al servidor.
  /// Llamado automáticamente al recuperar la red o manualmente.
  Future<void> processQueue() async {
    if (_isSyncing || _queue.isEmpty) return;

    _isSyncing = true;
    _lastSyncMessage = null;
    notifyListeners();

    final toProcess = List<_QueuedRequest>.from(_queue);
    int synced = 0;
    int failed = 0;

    for (final item in toProcess) {
      try {
        final response = await http
            .post(
              Uri.parse(ApiConstants.baseUrl + item.path),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${item.token}',
              },
              body: json.encode(item.params),
            )
            .timeout(
              const Duration(milliseconds: ApiConstants.receiveTimeout),
            );

        if (response.statusCode == 200 || response.statusCode == 201) {
          _queue.remove(item);
          synced++;
        } else {
          item.retries++;
          if (item.retries >= _maxRetries) {
            _queue.remove(item);
            failed++;
          }
        }
      } catch (_) {
        item.retries++;
        if (item.retries >= _maxRetries) {
          _queue.remove(item);
          failed++;
        }
      }
    }

    await _saveQueue();
    _isSyncing = false;

    if (synced > 0 || failed > 0) {
      _lastSyncMessage = synced > 0
          ? '$synced operación(es) sincronizada(s)'
          : null;
    }

    notifyListeners();
  }

  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_queueKey);
      if (raw == null) return;
      final list = json.decode(raw) as List<dynamic>;
      _queue.addAll(
        list.map((e) => _QueuedRequest.fromMap(e as Map<String, dynamic>)),
      );
      notifyListeners();
    } catch (_) {
      // Cola corrupta: ignorar
    }
  }

  Future<void> _saveQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _queueKey,
      json.encode(_queue.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> clearQueue() async {
    _queue.clear();
    await _saveQueue();
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
