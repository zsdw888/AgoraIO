import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
        responseDataCallback: (Map<String, dynamic>? data) async {
      await writeResponseData(
        data?['performance'] as Map<String, dynamic>,
        testOutputFilename: 'e2e_perf_summary',
      );
    });
