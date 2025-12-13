import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';

final PB = PocketBase('http://192.168.99.140:8090', reuseHTTPClient: true);

final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_CBC_PKCS7Padding,
  ),
);

class ApiService {
  static Future<bool> login_withpass(String email, String password) async {
    try {
      print("Logging in with email");
      // get user id from email
      //

      final authData = await PB
          .collection("users")
          .authWithPassword(email, password);

      final userid = PB.authStore.record!.id;
      // print(userid);
      PB.authStore.onChange.every((event) {
        print("Auth store changed:");
        Save_token_to_storage(event.token, userid);

        return true;
      });
      if (PB.authStore.isValid) {
        await Save_token_to_storage(PB.authStore.token, userid);
      }
      // get user id#

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  //
  static Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String nic,
    required String phone,
  }) async {
    try {
      final userData = await PB
          .collection("users")
          .create(
            body: {
              "email": email,
              "password": password,
              "passwordConfirm": password,
              "name": name,
              "nic": nic,
              "phone": phone,
            },
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> Save_token_to_storage(String token, String id) async {
    await storage.write(key: "vv_token", value: token);
    await storage.write(key: "vv_id", value: id);
    print("Saved token to secure_storage");
  }

  static Future logout() async {
    await storage.delete(key: "vv_token");
    await storage.delete(key: "vv_id");
    PB.authStore.clear();
    print("Logged out and cleared secure storage");
  }
}
