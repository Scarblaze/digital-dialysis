// lib/controllers/patient_info_controller.dart
import 'dart:convert';
import 'package:digitaldailysis/utils/app_constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:digitaldailysis/models/patient/patient_info_model.dart';
import 'package:digitaldailysis/data/api/api_client.dart';

class PatientInfoController extends GetxController {
  // Single material session details (doctor view)
  var isMaterialSessionLoading = false.obs;
  var materialSessionError = ''.obs;
  Rx<MaterialSessionResponse?> materialSessionDetails = Rx(null);
  final String patientId;
  PatientInfoController({required this.patientId});

  var isLoading = false.obs;
  var errorMsg = ''.obs;
  var responseModel = Rxn<PatientInfoResponse>();

  late ApiClient apiClient;

  @override
  void onInit() {
    super.onInit();
    apiClient = Get.find<ApiClient>();
    fetchPatientInfo();
  }

  /// Fetch patient material summary, which returns patient + materialSessions + days
  Future<void> fetchPatientInfo() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';

      // IMPORTANT: this is the material-summary endpoint you showed in Postman
      final uri = '${apiClient.appBaseUrl}/api/upload/patient/material-summary';

      // apiClient.postData expects a full URI string and a JSON body (it handles auth header)
      final http.Response res = await apiClient.postData(uri, {'patientId': patientId});

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        // ensure correct structure before parsing
        if (body['success'] == true && body['patient'] != null) {
          responseModel.value = PatientInfoResponse.fromJson(body);
        } else {
          errorMsg.value = 'No data in response';
          print('fetchPatientInfo: unexpected response body: $body');
        }
      } else {
        errorMsg.value = 'Server error: ${res.statusCode}';
        print('fetchPatientInfo failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      errorMsg.value = 'Failed to fetch patient info';
      print('fetchPatientInfo err: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Public helper to refresh page (pull-to-refresh etc)
  Future<void> refresh() async {
    await fetchPatientInfo();
  }

  /// Bucket logic — unchanged
  // String sessionBucket(MaterialSession ms) {
  //   final days = ms.days;
  //   if (days.isEmpty) return 'pending';
  //   final completed = days.where((d) => d.status.toLowerCase() == 'completed').length;
  //   final pending = days.where((d) => d.status.toLowerCase() == 'pending').length;
  //   if (completed > 0 && pending == 0) return 'completed';
  //   if (completed > 0 && pending > 0) return 'active';
  //   return 'pending';
  // }

  // List<MaterialSession> getCompletedSessions() {
  //   final m = responseModel.value?.materialSessions ?? [];
  //   return m.where((s) => sessionBucket(s) == 'completed').toList();
  // }
  //
  // List<MaterialSession> getActiveSessions() {
  //   final m = responseModel.value?.materialSessions ?? [];
  //   return m.where((s) => sessionBucket(s) == 'active').toList();
  // }
  //
  // List<MaterialSession> getPendingSessions() {
  //   final m = responseModel.value?.materialSessions ?? [];
  //   return m.where((s) => sessionBucket(s) == 'pending').toList();
  // }

  /// Fetch single material session details (Doctor view)
  Future<void> fetchMaterialSessionDetailsByDoc({
    required String patientId,
    required String materialSessionId,
  }) async {
    try {
      isMaterialSessionLoading.value = true;
      materialSessionError.value = '';

      final uri =
          '${apiClient.appBaseUrl}/api/upload/material/session-details';

      final http.Response res = await apiClient.postData(
        uri,
        {
          'patientId': patientId,
          'materialSessionId': materialSessionId,
        },
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);

        if (body['success'] == true) {
          materialSessionDetails.value =
              MaterialSessionResponse.fromJson(body);
          print("printing the response");
          print(materialSessionDetails.value);
        } else {
          materialSessionError.value =
              body['message'] ?? 'Invalid response from server';
          print('session-details unexpected body: $body');
        }
      } else {
        materialSessionError.value = 'Server error: ${res.statusCode}';
        print('session-details failed: ${res.statusCode} ${res.body}');
      }
    } catch (e, stack) {
      materialSessionError.value = 'Failed to load session details';
      print('fetchMaterialSessionDetailsByDoc error: $e');
      print(stack);
    } finally {
      isMaterialSessionLoading.value = false;
    }
  }



  var isLoadingCompleteDetails = false.obs;
  var completePatientDetails = Rx<CompletePatientDetails?>(null);
  var completeDetailsError = ''.obs;



  Future<void> fetchCompletePatientDetails(String patientId) async {
    try {
      isLoadingCompleteDetails.value = true;
      completeDetailsError.value = '';


      final response = await apiClient.postData(
        '${AppConstants.BASE_URL}/api/upload/medical-profile', {"patientId": patientId}
      );

      print("Complete Patient Details Response: ${response.statusCode}");
      print("Complete Patient Details Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.toString());
        completePatientDetails.value = CompletePatientDetails.fromJson(data);
      } else {
        completeDetailsError.value = 'Failed to load patient details';
      }
    } catch (e) {
      completeDetailsError.value = 'Error: ${e.toString()}';
      print("Exception in fetchCompletePatientDetails: $e");
    } finally {
      isLoadingCompleteDetails.value = false;
    }
  }



}

// Model for complete patient details
class CompletePatientDetails {
  final MedicalProfile? medicalProfile;
  final BaselineAssessment? baselineAssessment;

  CompletePatientDetails({
    this.medicalProfile,
    this.baselineAssessment,
  });

  factory CompletePatientDetails.fromJson(Map<String, dynamic> json) {
    return CompletePatientDetails(
      medicalProfile: json['medicalProfile'] != null
          ? MedicalProfile.fromJson(json['medicalProfile'])
          : null,
      baselineAssessment: json['baselineAssessment'] != null
          ? BaselineAssessment.fromJson(json['baselineAssessment'])
          : null,
    );
  }
}

class MedicalProfile {
  final String? patientId;
  final int? age;
  final String? gender;
  final String? crNumber;
  final String? contactNumber;
  final String? address;
  final String? educationLevel;
  final String? incomeLevel;
  final String? primaryDiagnosis;
  final String? nativeKidneyDisease;
  final String? dialysisType;
  final List<String>? allergies;
  final EmergencyContact? emergencyContact;

  MedicalProfile({
    this.patientId,
    this.age,
    this.gender,
    this.crNumber,
    this.contactNumber,
    this.address,
    this.educationLevel,
    this.incomeLevel,
    this.primaryDiagnosis,
    this.nativeKidneyDisease,
    this.dialysisType,
    this.allergies,
    this.emergencyContact,
  });

  factory MedicalProfile.fromJson(Map<String, dynamic> json) {
    return MedicalProfile(
      patientId: json['patientId'],
      age: json['age'],
      gender: json['gender'],
      crNumber: json['crNumber'],
      contactNumber: json['contactNumber'],
      address: json['address'],
      educationLevel: json['educationLevel'],
      incomeLevel: json['incomeLevel'],
      primaryDiagnosis: json['primaryDiagnosis'],
      nativeKidneyDisease: json['nativeKidneyDisease'],
      dialysisType: json['dialysisType'],
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : null,
      emergencyContact: json['emergencyContact'] != null
          ? EmergencyContact.fromJson(json['emergencyContact'])
          : null,
    );
  }
}

class EmergencyContact {
  final String? name;
  final String? phone;
  final String? relation;

  EmergencyContact({this.name, this.phone, this.relation});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      phone: json['phone'],
      relation: json['relation'],
    );
  }
}

class BaselineAssessment {
  final String? primaryDiagnosis;
  final String? nativeKidneyDisease;
  final String? dialysisType;
  final String? pdCatheterInsertionDate;
  final String? catheterTechnique;
  final String? pdStartDate;
  final String? trainingStartDate;
  final String? trainingCompletionDate;
  final PeriImplantComplications? periImplantComplications;
  final ClinicalExam? clinicalExam;
  final List<PdPrescription>? pdPrescription;
  final Labs? labs;
  final PlanAndAdvice? planAndAdvice;

  BaselineAssessment({
    this.primaryDiagnosis,
    this.nativeKidneyDisease,
    this.dialysisType,
    this.pdCatheterInsertionDate,
    this.catheterTechnique,
    this.pdStartDate,
    this.trainingStartDate,
    this.trainingCompletionDate,
    this.periImplantComplications,
    this.clinicalExam,
    this.pdPrescription,
    this.labs,
    this.planAndAdvice,
  });

  factory BaselineAssessment.fromJson(Map<String, dynamic> json) {
    return BaselineAssessment(
      primaryDiagnosis: json['primaryDiagnosis'],
      nativeKidneyDisease: json['nativeKidneyDisease'],
      dialysisType: json['dialysisType'],
      pdCatheterInsertionDate: json['pdCatheterInsertionDate'],
      catheterTechnique: json['catheterTechnique'],
      pdStartDate: json['pdStartDate'],
      trainingStartDate: json['trainingStartDate'],
      trainingCompletionDate: json['trainingCompletionDate'],
      periImplantComplications: json['periImplantComplications'] != null
          ? PeriImplantComplications.fromJson(json['periImplantComplications'])
          : null,
      clinicalExam: json['clinicalExam'] != null
          ? ClinicalExam.fromJson(json['clinicalExam'])
          : null,
      pdPrescription: json['pdPrescription'] != null
          ? (json['pdPrescription'] as List)
          .map((e) => PdPrescription.fromJson(e))
          .toList()
          : null,
      labs: json['labs'] != null ? Labs.fromJson(json['labs']) : null,
      planAndAdvice: json['planAndAdvice'] != null
          ? PlanAndAdvice.fromJson(json['planAndAdvice'])
          : null,
    );
  }
}

class PeriImplantComplications {
  final bool? present;
  final String? details;

  PeriImplantComplications({this.present, this.details});

  factory PeriImplantComplications.fromJson(Map<String, dynamic> json) {
    return PeriImplantComplications(
      present: json['present'],
      details: json['details'],
    );
  }
}

class ClinicalExam {
  final int? pulse;
  final int? bpSystolic;
  final int? bpDiastolic;
  final double? weightKg;
  final double? heightCm;
  final bool? pallor;
  final bool? icterus;
  final bool? cyanosis;
  final bool? clubbing;
  final bool? edema;

  ClinicalExam({
    this.pulse,
    this.bpSystolic,
    this.bpDiastolic,
    this.weightKg,
    this.heightCm,
    this.pallor,
    this.icterus,
    this.cyanosis,
    this.clubbing,
    this.edema,
  });

  factory ClinicalExam.fromJson(Map<String, dynamic> json) {
    return ClinicalExam(
      pulse: json['pulse'],
      bpSystolic: json['bpSystolic'],
      bpDiastolic: json['bpDiastolic'],
      weightKg: json['weightKg']?.toDouble(),
      heightCm: json['heightCm']?.toDouble(),
      pallor: json['pallor'],
      icterus: json['icterus'],
      cyanosis: json['cyanosis'],
      clubbing: json['clubbing'],
      edema: json['edema'],
    );
  }
}

class PdPrescription {
  final String? dwellTiming;
  final String? solutionStrength;
  final int? fillVolume;
  final int? dwellDurationHours;
  final int? numberOfExchanges;
  final bool? icodextrinUsed;

  PdPrescription({
    this.dwellTiming,
    this.solutionStrength,
    this.fillVolume,
    this.dwellDurationHours,
    this.numberOfExchanges,
    this.icodextrinUsed,
  });

  factory PdPrescription.fromJson(Map<String, dynamic> json) {
    return PdPrescription(
      dwellTiming: json['dwellTiming'],
      solutionStrength: json['solutionStrength'],
      fillVolume: json['fillVolume'],
      dwellDurationHours: json['dwellDurationHours'],
      numberOfExchanges: json['numberOfExchanges'],
      icodextrinUsed: json['icodextrinUsed'],
    );
  }
}

class Labs {
  final LabValue? hemoglobin;
  final LabValue? urea;
  final LabValue? creatinine;

  Labs({this.hemoglobin, this.urea, this.creatinine});

  factory Labs.fromJson(Map<String, dynamic> json) {
    return Labs(
      hemoglobin: json['hemoglobin'] != null
          ? LabValue.fromJson(json['hemoglobin'])
          : null,
      urea: json['urea'] != null ? LabValue.fromJson(json['urea']) : null,
      creatinine: json['creatinine'] != null
          ? LabValue.fromJson(json['creatinine'])
          : null,
    );
  }
}

class LabValue {
  final double? value;
  final String? date;

  LabValue({this.value, this.date});

  factory LabValue.fromJson(Map<String, dynamic> json) {
    return LabValue(
      value: json['value']?.toDouble(),
      date: json['date'],
    );
  }
}

class PlanAndAdvice {
  final String? advisedPrescription;
  final String? medications;
  final String? followUpInstructions;

  PlanAndAdvice({
    this.advisedPrescription,
    this.medications,
    this.followUpInstructions,
  });

  factory PlanAndAdvice.fromJson(Map<String, dynamic> json) {
    return PlanAndAdvice(
      advisedPrescription: json['advisedPrescription'],
      medications: json['medications'],
      followUpInstructions: json['followUpInstructions'],
    );
  }
}


