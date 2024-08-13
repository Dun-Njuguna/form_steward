import 'package:http/http.dart' as http;

/// A service for fetching form configuration data from a remote server.
///
/// The [ApiService] class provides a method to retrieve form configuration data
/// from a given URL. It uses HTTP GET requests to fetch the data and handles
/// responses and errors accordingly.
class ApiService {
  final http.Client client;

  ApiService({required this.client});

  Future<String> fetchFormJson(String url) async {
    final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
