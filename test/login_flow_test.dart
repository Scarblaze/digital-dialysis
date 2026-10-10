import 'dart:convert';

import 'package:digitaldailysis/controllers/doctor_controller.dart';
import 'package:digitaldailysis/controllers/doctor_material_controller.dart';
import 'package:digitaldailysis/controllers/login_controller.dart';
import 'package:digitaldailysis/controllers/patient_panel_controller.dart';
import 'package:digitaldailysis/data/api/api_client.dart';
import 'package:digitaldailysis/data/repository/doctor_repo.dart';
import 'package:digitaldailysis/data/repository/login_repo.dart';
import 'package:digitaldailysis/pages/auth/LoginPage.dart';
import 'package:digitaldailysis/pages/doctor/doctor_home_screen.dart';
import 'package:digitaldailysis/pages/patient/patient_home_screen.dart';
import 'package:digitaldailysis/routes/route_helper.dart';
import 'package:digitaldailysis/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ApiClient that answers from a map of path -> response instead of the network.
class FakeApiClient extends ApiClient {
  final Map<String, http.Response> responses;
  final List<String> calls = [];

  FakeApiClient({required super.sharedPreferences, required this.responses})
      : super(appBaseUrl: AppConstants.BASE_URL);

  http.Response _respond(String uri) {
    final path = Uri.parse(uri).path;
    calls.add(path);
    return responses[path] ?? http.Response('{"success":false}', 404);
  }

  @override
  Future<http.Response> postData(String uri, dynamic body) async => _respond(uri);

  @override
  Future<http.Response> patchData(String uri, dynamic body) async => _respond(uri);
}

Future<FakeApiClient> setUpApp(Map<String, http.Response> responses,
    {Map<String, Object> prefs = const {}}) async {
  Get.reset();
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final api = FakeApiClient(sharedPreferences: sp, responses: responses);
  Get.put<ApiClient>(api, permanent: true);
  Get.put(LoginRepo(apiClient: api), permanent: true);
  Get.put(DoctorRepo(apiClient: api), permanent: true);
  Get.put(LoginController(loginRepo: Get.find()), permanent: true);
  Get.put(DoctorController(doctorRepo: Get.find()), permanent: true);
  Get.put(DoctorMaterialController(apiClient: api), permanent: true);
  return api;
}

/// Portrait phone-sized surface (the app is locked to portrait).
void usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Widget testApp() => GetMaterialApp(
      initialRoute: RouteHelper.getLoginPage(),
      getPages: RouteHelper.routes,
    );

Future<void> submitLogin(WidgetTester tester, String id, String pw) async {
  await tester.enterText(find.byType(TextField).at(0), id);
  await tester.enterText(find.byType(TextField).at(1), pw);
  await tester.tap(find.text('Login'));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Lets GetX snackbars finish their timers so the test ends cleanly.
Future<void> drainSnackbars(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  const summaryPath = '/api/upload/patient/material-summary';

  testWidgets('server crash (non-JSON 500) shows a clear error and stays on login',
      (tester) async {
    await setUpApp({
      '/api/auth/login':
          http.Response('A server error has occurred\n\nFUNCTION_INVOCATION_FAILED', 500),
    });
    usePhoneSurface(tester);
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    await submitLogin(tester, 'doc@example.com', 'secret');

    expect(find.textContaining('Server is unavailable (HTTP 500)'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
    await drainSnackbars(tester);
  });

  testWidgets('empty credentials are rejected without calling the server',
      (tester) async {
    final api = await setUpApp({});
    usePhoneSurface(tester);
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    await submitLogin(tester, '', '');

    expect(find.textContaining('Please enter your Login ID'), findsOneWidget);
    expect(api.calls, isEmpty);
    await drainSnackbars(tester);
  });

  testWidgets('patient login with "_id" opens patient home and saves the session',
      (tester) async {
    final api = await setUpApp({
      '/api/auth/login': http.Response(
          jsonEncode({
            'token': 'tok123',
            'user': {'_id': 'p42', 'role': 'patient'},
          }),
          200),
      summaryPath: http.Response('{"success":false}', 500),
    });
    usePhoneSurface(tester);
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    await submitLogin(tester, 'pat@example.com', 'secret');
    await tester.pumpAndSettle();

    expect(find.byType(PatientHomeScreen), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing); // login removed from back stack
    expect(Get.isRegistered<PatientPanelController>(tag: 'p42'), isTrue);
    expect(api.calls, contains(summaryPath));
    expect(api.mainHeaders['Authorization'], 'Bearer tok123');
    expect(api.sharedPreferences.getString(AppConstants.USER_ID), 'p42');
    expect(api.sharedPreferences.getString(AppConstants.USER_ROLE), 'patient');
    // Failed summary shows the error with a retry, not a blank "No data"
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('doctor login opens doctor home; logout clears session',
      (tester) async {
    final api = await setUpApp({
      '/api/auth/login': http.Response(
          jsonEncode({
            'token': 'doctok',
            'user': {'id': 'd1', 'role': 'doctor'},
          }),
          200),
      '/api/upload/doctor/patients': http.Response(
          jsonEncode({
            'success': true,
            'patients': [
              {'_id': 'p1', 'name': 'Asha', 'email': 'asha@example.com'},
            ],
          }),
          200),
    });
    usePhoneSurface(tester);
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    await submitLogin(tester, 'doc@example.com', 'secret');
    await tester.pumpAndSettle();

    expect(find.byType(DoctorHomePage), findsOneWidget);
    expect(find.text('Asha'), findsOneWidget);

    await tester.tap(find.byTooltip('Logout'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(api.sharedPreferences.getString(AppConstants.TOKEN), isNull);
    expect(api.mainHeaders.containsKey('Authorization'), isFalse);
  });

  testWidgets('saved session is restored without logging in again', (tester) async {
    await setUpApp({
      summaryPath: http.Response('{"success":false}', 500),
    }, prefs: {
      AppConstants.TOKEN: 'tok',
      AppConstants.USER_ROLE: 'patient',
      AppConstants.USER_ID: 'p7',
    });
    usePhoneSurface(tester);
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    expect(Get.find<LoginController>().restoreSession(), isTrue);
    await tester.pumpAndSettle();

    expect(find.byType(PatientHomeScreen), findsOneWidget);
    expect(Get.isRegistered<PatientPanelController>(tag: 'p7'), isTrue);
  });
}
