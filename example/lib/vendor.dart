import 'package:inject_creator/inject_creator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
