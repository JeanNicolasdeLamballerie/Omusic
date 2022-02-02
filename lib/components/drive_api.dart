import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart' as http;

class DriveAPI {
  final http.Client client;
  late DriveApi api;
  var initialized = false;

  DriveAPI({required this.client}) : super();

  DriveApi initAPI() {
    initialized = true;
    api = DriveApi(client);
    return api;
  }

  DriveApi getAPI() {
    if (initialized) {
      return api;
    } else {
      return initAPI();
    }
  }

  DriveApi changeAPIuser(http.Client newClient) {
    api = DriveApi(newClient);
    return api;
  }
}