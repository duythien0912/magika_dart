import 'package:integration_test/integration_test.dart';

import '../lib/main.dart' as app;
import '../../integration_test/real_model_integration_test.dart' as real_model_test;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  app.main();
  real_model_test.defineRealModelIntegrationTests();
}
