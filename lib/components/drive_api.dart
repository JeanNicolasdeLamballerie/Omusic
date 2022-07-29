import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart' as http;

class DriveAPI {
  final http.Client client;
  late DriveApi api;
  var initialized = false;

  DriveAPI({required this.client}) : super();

  DriveApi initAPI({http.Client? replacementClient}) {
    initialized = true;
    if (replacementClient != null) {
      api = DriveApi(replacementClient);
      return api;
    }
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

  getData() {
    return {api.about, api.changes, api.files};
  }

  DriveApi changeAPIuser(http.Client newClient) {
    api = DriveApi(newClient);
    return api;
  }
}
