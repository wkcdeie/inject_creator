import 'package:inject_creator/inject_creator.dart';

@Singleton()
class LoginService {
  @PostConstruct()
  void init() {
    print('PostConstruct init');
  }
}

@Mutable()
class NoSingletonService {}

@LazySingleton()
class LazySingletonService {}

@Singleton(tag: 'customNameService')
class CustomNameService {}

abstract class AbstractService {}

@Singleton(tag: 'default', as: AbstractService)
class AbstractServiceImpl extends AbstractService {}

@LazySingleton(tag: 'simple', as: AbstractService)
class SimpleAbstractService extends AbstractService {}

@LazySingleton(tag: 'asyncService')
class AsyncService {
  @FactoryMethod()
  static Future<AsyncService> withDependencies(LoginService loginService) {
    return Future.value(AsyncService());
  }
}

@LazySingleton()
class FactoryMethodService {
  @FactoryMethod()
  static Future<FactoryMethodService> withDependencies(
      Future<AsyncService> asyncService,
      {@Alias.by(SimpleAbstractService)
          required AbstractService abstractService}) {
    return Future(() => FactoryMethodService());
  }
}

@LazySingleton()
class DbService {
  @DisposeMethod()
  void dispose() {}
}
