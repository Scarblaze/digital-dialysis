
import 'package:digitaldailysis/data/api/api_client.dart';
import 'package:digitaldailysis/utils/app_constants.dart';
import 'package:http/http.dart' as http;

class DoctorRepo {
  final ApiClient apiClient;

  DoctorRepo({required this.apiClient});

  Future<http.Response> getPatientsList(String doctorId) async {

    return await apiClient.postData(
      AppConstants.GET_DOCTOR_PATIENTS,
      {'doctorId': doctorId},
    );
  }

  Future<http.Response> postregisterPatient(
      String name, String email, String password, String doctorId) async {

      return await apiClient.postData(
        AppConstants.REGISTER_PATIENT,
        {
          "name": name,
          "email": email,
          "password": password,
          "role": "patient",
          "doctorId": doctorId,
        },
      );


  }



}
