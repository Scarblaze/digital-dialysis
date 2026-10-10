class AppConstants {
  // Override at build/run time with: --dart-define=BASE_URL=https://your-backend.example.com
  static const String BASE_URL = String.fromEnvironment(
    'BASE_URL',
    defaultValue: "https://backend-green-ten-55.vercel.app",
  );
  static const String LOGIN_URI = "$BASE_URL/api/auth/login";
  static const String TOKEN = "token";
  static const String USER_ROLE = "userRole";
  static const String USER_ID = "userId";
  static const String GET_DOCTOR_PATIENTS = "$BASE_URL/api/upload/doctor/patients";
  static const String REGISTER_PATIENT = "$BASE_URL/api/auth/register";
}
