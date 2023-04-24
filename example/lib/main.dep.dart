// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EnableInjectorGenerator
// **************************************************************************

import 'package:example/services.dart';
import 'package:example/vendor.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> configDependencies() {
  final it = GetIt.instance;
  it.registerLazySingletonAsync<AsyncService>(
      () => AsyncService.withDependencies(getLoginService()),
      instanceName: 'asyncService');
  it.registerSingleton<LoginService>(LoginService()..init());
  it.registerSingleton<AbstractService>(AbstractServiceImpl(),
      instanceName: 'default');
  it.registerSingleton<CustomNameService>(CustomNameService(),
      instanceName: 'customNameService');
  it.registerLazySingleton<DbService>(() => DbService(),
      dispose: (instance) => instance.dispose());
  it.registerLazySingletonAsync<FactoryMethodService>(() =>
      FactoryMethodService.withDependencies(getAsyncService(),
          abstractService: getAbstractService('simple')));
  it.registerLazySingleton<LazySingletonService>(() => LazySingletonService());
  it.registerFactory<NoSingletonService>(() => NoSingletonService());
  it.registerLazySingleton<AbstractService>(() => SimpleAbstractService(),
      instanceName: 'simple');
  it.registerSingleton<VendorComponent>(VendorComponent(),
      dispose: (instance) => instance.dispose());
  it.registerLazySingletonAsync<SharedPreferences>(
      () => getVendorComponent().sharedPreferences,
      instanceName: 'defaultSharedPreferences');
  return it.allReady();
}

Future<AsyncService> getAsyncService() =>
    GetIt.instance.getAsync<AsyncService>(instanceName: 'asyncService');

LoginService getLoginService() => GetIt.instance.get<LoginService>();

AbstractService getAbstractService<T extends AbstractService>([String? tag]) =>
    GetIt.instance.get<T>(instanceName: tag);

CustomNameService getCustomNameService() =>
    GetIt.instance.get<CustomNameService>(instanceName: 'customNameService');

DbService getDbService() => GetIt.instance.get<DbService>();

Future<FactoryMethodService> getFactoryMethodService() =>
    GetIt.instance.getAsync<FactoryMethodService>();

LazySingletonService getLazySingletonService() =>
    GetIt.instance.get<LazySingletonService>();

NoSingletonService getNoSingletonService() =>
    GetIt.instance.get<NoSingletonService>();

Future<SharedPreferences> getSharedPreferences() => GetIt.instance
    .getAsync<SharedPreferences>(instanceName: 'defaultSharedPreferences');

VendorComponent getVendorComponent() => GetIt.instance.get<VendorComponent>();
