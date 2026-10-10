import 'package:digitaldailysis/utils/app_constants.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/data/api/api_client.dart';

class DoctorMaterialController extends GetxController {
  final ApiClient apiClient;
  DoctorMaterialController({required this.apiClient});

  RxBool isVerifying = false.obs;

  Future<bool> verifyDialysisSession({
    required String sessionId,
    required String notes,
  }) async {
    try {
      isVerifying(true);

      final res = await apiClient.patchData(
        AppConstants.BASE_URL +
        '/api/upload/verify-dialysis-session',
        {
          "sessionId": sessionId,
          "verificationNotes": notes,
        },

      );
      print(res.body);
      if (res.statusCode == 200) {
        print("verified successfully");
        print(res);


        return true;
      } else {
        print("verificatrion failed");

        return false;
      }
    } catch (e) {

    } finally {
      isVerifying(false);
    }
    return false;
  }

}
