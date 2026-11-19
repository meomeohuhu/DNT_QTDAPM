import 'package:flutter_test/flutter_test.dart';
import 'package:freshfarm/models/batch_model.dart';
import 'package:freshfarm/providers/traceability_provider.dart';
import 'package:freshfarm/services/mock_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'new batch survives restart and QR must match the exact batch code',
    () async {
      SharedPreferences.setMockInitialValues({});
      final traceability = TraceabilityProvider();
      final batch = BatchModel.fromMap({
        ...MockDataService.getMockBatches().first.toMap(),
        'id': 'BATCH-LOCAL-TEST',
      });
      await traceability.addNewBatch(batch);

      final reopened = TraceabilityProvider();
      final found = await reopened.findBatch(
        ' freshfarm-trace:batch-local-test ',
      );
      expect(found?.id, batch.id);
      expect(
        await reopened.findBatch('FRESHFARM-TRACE:BATCH-LOCAL-TEST-INVALID'),
        isNull,
      );
      expect(reopened.selectedBatch, isNull);
      expect(await reopened.findBatch(''), isNull);
    },
  );
}
