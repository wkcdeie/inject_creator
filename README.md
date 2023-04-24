# inject_creator

[![Pub Version](https://img.shields.io/pub/v/inject_creator)](https://pub.dev/packages/inject_creator)

inject_creator is a convenient code generator for `get_it`.

## Features

- Singleton
- LazySingleton
- Mutable
- Alias
- FactoryMethod
- PostConstruct
- DisposeMethod
- Component

## Getting started

### Install

```yaml
dependencies:
  get_it: ^6.0.0
  inject_creator: any

dev_dependencies:
  build_runner: ^2.0.0
  inject_creator_generator: any
```

### Usage

```dart
import 'main.dep.dart';

@EnableInjector(allReady: true)
// or @EnableInjector(entryPoint:'initDependencies', allReady: false)
void main() {
  configDependencies();
  // or initDependencies();
  runApp(const MyApp());
}
```

example:

```dart
import 'main.dep.dart';

// sync
getXxxx();

// async
await getSharedPreferences();
```

generate code:

```shell
flutter pub run build_runner build
```

## Example

### Singleton

```dart
@Singleton()
class LoginService {}


@Singleton(tag: 'customNameService')
class CustomNameService {}

abstract class AbstractService {}

@Singleton(tag: 'default', as: AbstractService)
class AbstractServiceImpl extends AbstractService {}
```

### LazySingleton

```dart
@LazySingleton()
class LazySingletonService {}
```

### Mutable

```dart
@Mutable()
class NoSingletonService {}
```

### PostConstruct

```dart
@Singleton()
class LoginService {
  @PostConstruct()
  void init() {
    print('PostConstruct init');
  }
}
```

### FactoryMethod

```dart
@LazySingleton(tag: 'asyncService')
class AsyncService {
  @FactoryMethod()
  static Future<AsyncService> withDependencies(LoginService loginService) {
    return Future.value(AsyncService());
  }
}
```

### DisposeMethod

```dart
@LazySingleton()
class DbService {
  @DisposeMethod()
  void dispose() {}
}
```

### Alias

```dart
@LazySingleton()
class FactoryMethodService {
  @FactoryMethod()
  static Future<FactoryMethodService> withDependencies(
      {@Alias('asyncService')
      required Future<AsyncService> asyncService,
      @Alias.by(SimpleAbstractService)
          required AbstractService abstractService}) {
    return Future(() => FactoryMethodService());
  }
}
```

### Third party

```dart
@Component()
class VendorComponent {

  @LazySingleton(tag: 'defaultSharedPreferences')
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @DisposeMethod()
  void dispose() {
    sharedPreferences.then((value) => value.clear());
  }
}
```
