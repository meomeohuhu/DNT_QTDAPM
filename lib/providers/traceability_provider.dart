import 'package:flutter/material.dart';
import '../models/batch_model.dart';
import '../services/mock_data_service.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';

class TraceabilityProvider extends ChangeNotifier {
  List<BatchModel> _batches = [];
  BatchModel? _selectedBatch;
  bool _isLoading = false;

  List<BatchModel> get batches => _batches;
  BatchModel? get selectedBatch => _selectedBatch;
  bool get isLoading => _isLoading;

  late final Future<void> loadCompletion;

  TraceabilityProvider() {
    loadCompletion = loadBatches();
  }

  Future<void> loadBatches() async {
    _isLoading = true;
    notifyListeners();

    final cached = await StorageService.getBatches();
    if (cached != null && cached.isNotEmpty) {
      _batches = cached;
    } else {
      _batches = MockDataService.getMockBatches();
      await StorageService.saveBatches(_batches);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Searches for a batch by code, batchId, or scanned QR content
  Future<BatchModel?> findBatch(String query) async {
    await loadCompletion;
    const prefix = 'FRESHFARM-TRACE:';
    final input = query.trim().toUpperCase();
    final isTraceCode = input.startsWith(prefix);
    final code = isTraceCode ? input.substring(prefix.length).trim() : input;
    BatchModel? match;
    if (code.isNotEmpty) {
      for (final batch in _batches) {
        if (batch.id.toUpperCase() == code ||
            (!isTraceCode && batch.productId.toUpperCase() == code)) {
          match = batch;
          break;
        }
      }
      match ??= await FirebaseService.getBatchByCode(code);
    }
    _selectedBatch = match;
    notifyListeners();
    return match;
  }

  Future<void> addNewBatch(BatchModel batch) async {
    await loadCompletion;
    final updated = [batch, ..._batches.where((entry) => entry.id != batch.id)];
    await StorageService.saveBatches(updated);
    _batches = updated;
    await FirebaseService.syncBatchToFirestore(batch);
    notifyListeners();
  }
}

