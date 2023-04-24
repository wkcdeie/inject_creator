import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dep.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  configDependencies();
  test("Test Get Instance", () {
    expect(getLoginService(), isNotNull);
  });

  test("Test Singleton Instance", () {
    final service = getLoginService();
    expect(service, equals(getLoginService()));
  });

  test("Test No Singleton Instance", () {
    final service = getNoSingletonService();
    expect(service, isNot(getNoSingletonService()));
  });

  test("Test Lazy Instance", () {
    expect(getLazySingletonService(), isNotNull);
  });

  test("Test Async Instance", () {
    expect(getAsyncService(), isNotNull);
  });

  test("Test Async Dependencies Instance", () {
    expect(getFactoryMethodService(), isNotNull);
  });

  test("Test SharedPreferences", () {
    expect(getSharedPreferences(), isNotNull);
  });
}
