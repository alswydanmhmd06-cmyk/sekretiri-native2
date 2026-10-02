import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

void configureBrowserCredentials(Dio dio) {
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
}
