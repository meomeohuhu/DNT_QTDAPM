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

  TraceabilityProvider() {
    loadBatches();
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
    final clean = query.trim().toUpperCase();

    // 1. Check local list
    try {
      final found = _batches.firstWhere(
        (b) =>
            b.id.toUpperCase() == clean ||
            b.productId.toUpperCase() == clean ||
            clean.contains(b.id.toUpperCase()),
      );
      _selectedBatch = found;
      notifyListeners();
      return found;
    } catch (_) {}

    // 2. Check Firestore
    final cloudBatch = await FirebaseService.getBatchByCode(clean);
    if (cloudBatch != null) {
      _selectedBatch = cloudBatch;
      notifyListeners();
      return cloudBatch;
    }

    // Default to the first demo batch if search fails, to show rich demo UI
    if (_batches.isNotEmpty) {
      _selectedBatch = _batches.first;
      notifyListeners();
      return _selectedBatch;
    }
    return null;
  }

  Future<void> addNewBatch(BatchModel batch) async {
    _batches.insert(0, batch);
    await StorageService.saveBatches(_batches);
    await FirebaseService.syncBatchToFirestore(batch);
    notifyListeners();
  }
}

