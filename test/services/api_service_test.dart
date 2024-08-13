import 'package:flutter_test/flutter_test.dart';
import 'package:form_steward/src/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'api_service_test.mocks.dart'; // Generated mocks file

void main() {
  apiServiceTests();
}

// Generate a MockClient using the Mockito package.
@GenerateMocks([http.Client])
void apiServiceTests() {
  late MockClient mockClient;
  late ApiService apiService;

  setUp(() {
    mockClient = MockClient(); // No parameters needed here
    apiService = ApiService(client: mockClient);
  });

  test('fetchFormJson returns data if the HTTP call completes successfully',
      () async {
    // Arrange
    const url = 'https://example.com';
    when(mockClient.get(Uri.parse(url)))
        .thenAnswer((_) async => http.Response('{"key": "value"}', 200));

    // Act
    final result = await apiService.fetchFormJson(url);

    // Assert
    expect(result, equals('{"key": "value"}'));
  });

  test(
      'fetchFormJson throws an exception if the HTTP call completes with an error',
      () async {
    // Arrange
    const url = 'https://example.com';
    when(mockClient.get(Uri.parse(url)))
        .thenAnswer((_) async => http.Response('Not Found', 404));

    // Act & Assert
    expect(apiService.fetchFormJson(url), throwsException);
  });
}
