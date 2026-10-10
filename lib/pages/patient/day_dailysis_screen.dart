import 'dart:io';
import 'package:digitaldailysis/routes/route_helper.dart';
import 'package:digitaldailysis/utils/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/patient_panel_controller.dart';

class DayDialysisScreen extends StatefulWidget {
  final String sessionId;
  final int dayNumber;
  final String MaterialSessionId;
  final String patientId;

  const DayDialysisScreen({
    super.key,
    required this.sessionId,
    required this.dayNumber,
    required this.MaterialSessionId,
    required this.patientId,
  });

  @override
  State<DayDialysisScreen> createState() => _DayDialysisScreenState();
}

class _DayDialysisScreenState extends State<DayDialysisScreen> {
  // General Well-being (1-10 scale)
  double wellbeing = 7;

  // Gastrointestinal Symptoms
  bool appetite = true;
  bool nausea = false;
  bool vomiting = false;
  bool abdominalDiscomfort = false;
  bool constipation = false;
  bool diarrhea = false;

  // Energy & Sleep
  double sleepQuality = 6;
  bool fatigue = false;
  bool ableToDoActivities = true;

  // Fluid Status Indicators
  bool breathlessness = false;
  bool footSwelling = false;
  bool facialPuffiness = false;
  bool rapidWeightGain = false;

  // Blood Pressure
  bool bpMeasured = false;
  final sbpController = TextEditingController();
  final dbpController = TextEditingController();

  // Weight
  bool weightMeasured = false;
  final weightKgController = TextEditingController();

  // Dialysis-Specific Issues
  bool painDuringFillDrain = false;
  bool slowDrain = false;
  bool catheterLeak = false;
  bool exitSiteIssue = false;
  String effluentClarity = "clear";

  // Urine Output
  bool urinePassed = true;
  String urineAmount = "normal";
  bool fluidOverloadFeeling = false;

  // Red Flags
  bool fever = false;
  bool chills = false;
  bool newAbdominalPain = false;
  bool suddenUnwell = false;

  // Comments
  final commentsController = TextEditingController();

  // Dialysis Readings
  bool readingsMeasured = false;

  final fillVolumeController = TextEditingController();
  final drainVolumeController = TextEditingController();
  final fillTimeController = TextEditingController();
  final drainTimeController = TextEditingController();

  // Image
  File? selectedImage;
  Uint8List? webImage;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientPanelController>(tag: widget.patientId);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final padding = width * 0.04;

    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Session ${widget.dayNumber} - Health Assessment",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: width * 0.045,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Well-being Section
            _buildSectionCard(
              context: context,
              icon: Icons.mood,
              title: "General Well-being",
              color: AppStatusColors.success,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How are you feeling today? (1-10)",
                    style: TextStyle(
                      fontSize: width * 0.038,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: wellbeing,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: wellbeing.round().toString(),
                          activeColor: AppColors.darkPrimary,
                          onChanged: (value) {
                            setState(() {
                              wellbeing = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.03,
                          vertical: height * 0.008,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkPrimary,
                          borderRadius: BorderRadius.circular(width * 0.02),
                        ),
                        child: Text(
                          wellbeing.round().toString(),
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.04,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.025),

            // Gastrointestinal Symptoms
            _buildSectionCard(
              context: context,
              icon: Icons.restaurant,
              title: "Gastrointestinal Symptoms",
              color: AppStatusColors.info,
              child: Column(
                children: [
                  _buildCheckboxTile("Good Appetite", appetite, (val) => setState(() => appetite = val!)),
                  _buildCheckboxTile("Nausea", nausea, (val) => setState(() => nausea = val!)),
                  _buildCheckboxTile("Vomiting", vomiting, (val) => setState(() => vomiting = val!)),
                  _buildCheckboxTile("Abdominal Discomfort", abdominalDiscomfort, (val) => setState(() => abdominalDiscomfort = val!)),
                  _buildCheckboxTile("Constipation", constipation, (val) => setState(() => constipation = val!)),
                  _buildCheckboxTile("Diarrhea", diarrhea, (val) => setState(() => diarrhea = val!)),
                ],
              ),
            ),

            SizedBox(height: height * 0.025),

            // Energy & Sleep
            _buildSectionCard(
              context: context,
              icon: Icons.bedtime,
              title: "Energy & Sleep",
              color: AppStatusColors.active,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sleep Quality (1-10)",
                    style: TextStyle(
                      fontSize: width * 0.038,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: sleepQuality,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: sleepQuality.round().toString(),
                          activeColor: AppColors.darkPrimary,
                          onChanged: (value) {
                            setState(() {
                              sleepQuality = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.03,
                          vertical: height * 0.008,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkPrimary,
                          borderRadius: BorderRadius.circular(width * 0.02),
                        ),
                        child: Text(
                          sleepQuality.round().toString(),
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.04,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                  _buildCheckboxTile("Experiencing Fatigue", fatigue, (val) => setState(() => fatigue = val!)),
                  _buildCheckboxTile("Able to Do Daily Activities", ableToDoActivities, (val) => setState(() => ableToDoActivities = val!)),
                ],
              ),
            ),

            SizedBox(height: height * 0.025),

            // Fluid Status Indicators
            _buildSectionCard(
              context: context,
              icon: Icons.water_drop,
              title: "Fluid Status",
              color: AppStatusColors.warning,
              child: Column(
                children: [
                  _buildCheckboxTile("Breathlessness", breathlessness, (val) => setState(() => breathlessness = val!)),
                  _buildCheckboxTile("Foot Swelling", footSwelling, (val) => setState(() => footSwelling = val!)),
                  _buildCheckboxTile("Facial Puffiness", facialPuffiness, (val) => setState(() => facialPuffiness = val!)),
                  _buildCheckboxTile("Rapid Weight Gain", rapidWeightGain, (val) => setState(() => rapidWeightGain = val!)),
                  _buildCheckboxTile("Feeling Fluid Overload", fluidOverloadFeeling, (val) => setState(() => fluidOverloadFeeling = val!)),
                ],
              ),
            ),

            SizedBox(height: height * 0.025),

            // Vitals - Blood Pressure & Weight
            _buildSectionCard(
              context: context,
              icon: Icons.monitor_heart,
              title: "Vital Signs",
              color: AppColors.darkPrimary,
              child: Column(
                children: [
                  _buildCheckboxTile("Blood Pressure Measured", bpMeasured, (val) => setState(() => bpMeasured = val!)),
                  if (bpMeasured) ...[
                    SizedBox(height: height * 0.015),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            context: context,
                            controller: sbpController,
                            label: "Systolic BP",
                            hint: "e.g., 120",
                            icon: Icons.favorite,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: _buildTextField(
                            context: context,
                            controller: dbpController,
                            label: "Diastolic BP",
                            hint: "e.g., 80",
                            icon: Icons.favorite_border,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: height * 0.02),
                  _buildCheckboxTile("Weight Measured", weightMeasured, (val) => setState(() => weightMeasured = val!)),
                  if (weightMeasured) ...[
                    SizedBox(height: height * 0.015),
                    _buildTextField(
                      context: context,
                      controller: weightKgController,
                      label: "Weight (kg)",
                      hint: "e.g., 68.5",
                      icon: Icons.scale,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: height * 0.025),

            // Dialysis-Specific Issues
            _buildSectionCard(
              context: context,
              icon: Icons.medical_services,
              title: "Dialysis-Specific Issues",
              color: AppStatusColors.error,
              child: Column(
                children: [
                  _buildCheckboxTile("Pain During Fill/Drain", painDuringFillDrain, (val) => setState(() => painDuringFillDrain = val!)),
                  _buildCheckboxTile("Slow Drain", slowDrain, (val) => setState(() => slowDrain = val!)),
                  _buildCheckboxTile("Catheter Leak", catheterLeak, (val) => setState(() => catheterLeak = val!)),
                  _buildCheckboxTile("Exit Site Issue", exitSiteIssue, (val) => setState(() => exitSiteIssue = val!)),
                  SizedBox(height: height * 0.02),
                  _buildDropdownField(
                    context: context,
                    label: "Effluent Clarity",
                    value: effluentClarity,
                    items: ["clear", "cloudy", "bloody"],
                    onChanged: (val) => setState(() => effluentClarity = val!),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.025),

            // Urine Output
            _buildSectionCard(
              context: context,
              icon: Icons.local_drink,
              title: "Urine Output",
              color: AppStatusColors.info,
              child: Column(
                children: [
                  _buildCheckboxTile("Urine Passed", urinePassed, (val) => setState(() => urinePassed = val!)),
                  if (urinePassed) ...[
                    SizedBox(height: height * 0.015),
                    _buildDropdownField(
                      context: context,
                      label: "Urine Amount",
                      value: urineAmount,
                      items: ["normal", "reduced", "increased", "none"],
                      onChanged: (val) => setState(() => urineAmount = val!),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: height * 0.025),

            // Red Flags
            _buildSectionCard(
              context: context,
              icon: Icons.warning,
              title: "⚠️ Warning Signs",
              color: Colors.red,
              child: Column(
                children: [
                  _buildCheckboxTile("Fever", fever, (val) => setState(() => fever = val!)),
                  _buildCheckboxTile("Chills", chills, (val) => setState(() => chills = val!)),
                  _buildCheckboxTile("New Abdominal Pain", newAbdominalPain, (val) => setState(() => newAbdominalPain = val!)),
                  _buildCheckboxTile("Suddenly Feeling Unwell", suddenUnwell, (val) => setState(() => suddenUnwell = val!)),
                ],
              ),
            ),

            SizedBox(height: height * 0.025),

            // Comments
            _buildSectionCard(
              context: context,
              icon: Icons.comment,
              title: "Additional Comments",
              color: AppStatusColors.verified,
              child: _buildTextField(
                context: context,
                controller: commentsController,
                label: "Comments",
                hint: "Share any additional observations or concerns...",
                maxLines: 4,
                icon: Icons.chat_bubble_outline,
              ),
            ),

            SizedBox(height: height * 0.025),

            // Image Upload Card
            _buildSectionCard(
              context: context,
              icon: Icons.photo_camera_rounded,
              title: "Session Photo",
              color: AppStatusColors.info,
              child: Column(
                children: [
                  if (selectedImage != null || webImage != null)
                    Container(
                      height: height * 0.25,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * 0.03),
                        border: Border.all(
                            color: AppColors.darkPrimary.withValues(alpha: 0.3),
                            width: 2),
                        image: DecorationImage(
                          image: kIsWeb
                              ? MemoryImage(webImage!) as ImageProvider
                              : FileImage(selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      height: height * 0.18,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(width * 0.03),
                        border: Border.all(
                          color: AppColors.mediumGrey.withValues(alpha: 0.5),
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: width * 0.12,
                              color: AppColors.mediumGrey,
                            ),
                            SizedBox(height: height * 0.01),
                            Text(
                              "No photo added",
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: width * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: height * 0.02),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        if (kIsWeb) {
                          final bytes = await picked.readAsBytes();
                          setState(() {
                            webImage = bytes;
                          });
                        } else {
                          setState(() {
                            selectedImage = File(picked.path);
                          });
                        }
                      }
                    },
                    icon: Icon(
                        (selectedImage == null && webImage == null)
                            ? Icons.add_a_photo
                            : Icons.edit,
                        size: width * 0.045),
                    label: Text(
                      (selectedImage == null && webImage == null)
                          ? "Add Photo"
                          : "Change Photo",
                      style: TextStyle(
                        fontSize: width * 0.038,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppStatusColors.info,
                      side: BorderSide(color: AppStatusColors.info, width: 2),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.06,
                        vertical: height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.025),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.025),

            _buildSectionCard(
              context: context,
              icon: Icons.science,
              title: "Dialysis Readings",
              color: AppStatusColors.active,
              child: Column(
                children: [
                  _buildCheckboxTile(
                    "Enter Dialysis Readings",
                    readingsMeasured,
                        (val) => setState(() => readingsMeasured = val!),
                  ),

                  if (readingsMeasured) ...[
                    SizedBox(height: height * 0.02),

                    _buildTextField(
                      context: context,
                      controller: fillVolumeController,
                      label: "Fill Volume (ml)",
                      hint: "e.g., 2000",
                      icon: Icons.water_drop,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: height * 0.015),

                    _buildTextField(
                      context: context,
                      controller: drainVolumeController,
                      label: "Drain Volume (ml)",
                      hint: "e.g., 1950",
                      icon: Icons.water,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: height * 0.015),

                    _buildTextField(
                      context: context,
                      controller: fillTimeController,
                      label: "Fill Time (minutes)",
                      hint: "e.g., 12",
                      icon: Icons.timer,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: height * 0.015),

                    _buildTextField(
                      context: context,
                      controller: drainTimeController,
                      label: "Drain Time (minutes)",
                      hint: "e.g., 15",
                      icon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: height * 0.04),

            // Finish Button
            Obx(() {
              return controller.isLoading.value
                  ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.darkPrimary,
                ),
              )
                  : SizedBox(
                width: double.infinity,
                height: height * 0.07,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    /// 1. Upload image (if selected)
                    if(selectedImage == null)
                      {
                        print("Null image selected");
                      }
                    if (selectedImage != null) {
                      await controller.uploadDialysisImage(
                        widget.sessionId,
                        selectedImage!.path,
                      );
                    }

                    /// 2. Prepare symptoms data according to new API structure
                    final symptomsData = {
                      "sessionId": widget.sessionId,
                      "symptoms": {
                        "wellbeing": wellbeing.round(),
                        "appetite": appetite,
                        "nausea": nausea,
                        "vomiting": vomiting,
                        "abdominalDiscomfort": abdominalDiscomfort,
                        "constipation": constipation,
                        "diarrhea": diarrhea,
                        "sleepQuality": sleepQuality.round(),
                        "fatigue": fatigue,
                        "ableToDoActivities": ableToDoActivities,
                        "breathlessness": breathlessness,
                        "footSwelling": footSwelling,
                        "facialPuffiness": facialPuffiness,
                        "rapidWeightGain": rapidWeightGain,
                        "bpMeasured": bpMeasured,
                        if (bpMeasured) "sbp": int.tryParse(sbpController.text) ?? 0,
                        if (bpMeasured) "dbp": int.tryParse(dbpController.text) ?? 0,
                        "weightMeasured": weightMeasured,
                        if (weightMeasured) "weightKg": double.tryParse(weightKgController.text) ?? 0.0,
                        "painDuringFillDrain": painDuringFillDrain,
                        "slowDrain": slowDrain,
                        "catheterLeak": catheterLeak,
                        "exitSiteIssue": exitSiteIssue,
                        "effluentClarity": effluentClarity,
                        "urinePassed": urinePassed,
                        "urineAmount": urineAmount,
                        "fluidOverloadFeeling": fluidOverloadFeeling,
                        "fever": fever,
                        "chills": chills,
                        "newAbdominalPain": newAbdominalPain,
                        "suddenUnwell": suddenUnwell,
                        "comments": commentsController.text,
                      },
                      if (readingsMeasured)
                        "readings": {
                          "fillVolume": int.tryParse(fillVolumeController.text) ?? 0,
                          "drainVolume": int.tryParse(drainVolumeController.text) ?? 0,
                          "fillTime": int.tryParse(fillTimeController.text) ?? 0,
                          "drainTime": int.tryParse(drainTimeController.text) ?? 0,
                        }
                    };

                    /// 3. Finish dialysis (main API)
                    final success = await controller.finishDialysisDay(
                      widget.sessionId,
                      symptomsData,
                    );

                    if (success) {
                      /// 4. Show success snackbar
                      Get.snackbar(
                        "Success",
                        "Dialysis Session Completed Successfully",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppStatusColors.verified,
                        colorText: AppColors.white,
                        icon: Icon(Icons.check_circle,
                            color: AppColors.white),
                      );

                      /// 5. Refresh data
                      await controller.fetchMaterialSessionDetails(
                          widget.MaterialSessionId);

                      /// 6. Navigate back
                      Get.offNamedUntil(
                        RouteHelper.getPatientMaterialSessionDetails(
                            widget.MaterialSessionId, widget.patientId),
                        // keep the patient home screen underneath
                            (route) =>
                        route.settings.name?.startsWith(
                                RouteHelper.patientHomeScreen) ??
                            false,
                      );
                    }
                  },
                  icon: Icon(Icons.check_circle_outline_rounded,
                      size: width * 0.06),
                  label: Text(
                    "Complete Session",
                    style: TextStyle(
                      fontSize: width * 0.042,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStatusColors.verified,
                    foregroundColor: AppColors.white,
                    elevation: 4,
                    shadowColor:
                    AppStatusColors.verified.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.03),
                    ),
                  ),
                ),
              );
            }),

            SizedBox(height: height * 0.025),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(width * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(width * 0.045),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(width * 0.04),
                topRight: Radius.circular(width * 0.04),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(width * 0.02),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(width * 0.02),
                  ),
                  child: Icon(icon, color: color, size: width * 0.055),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: width * 0.043,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(width * 0.045),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(
      String label, bool value, Function(bool?) onChanged) {
    final width = MediaQuery.of(context).size.width;

    return CheckboxListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: width * 0.038,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.darkPrimary,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final width = MediaQuery.of(context).size.width;

    return DropdownButtonFormField<String>(
      key: ValueKey("$label:$value"),
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: width * 0.036,
          color: AppColors.darkGrey,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: AppColors.lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.025),
          borderSide: BorderSide(color: AppColors.mediumGrey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.025),
          borderSide: BorderSide(
            color: AppColors.mediumGrey.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.025),
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item.capitalizeFirst!,
            style: TextStyle(fontSize: width * 0.038),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: width * 0.038,
        color: AppColors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: width * 0.036,
          color: AppColors.darkGrey,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: width * 0.035,
          color: AppColors.mediumGrey,
        ),
        prefixIcon: icon != null
            ? Icon(
          icon,
          size: width * 0.05,
          color: AppColors.darkPrimary,
        )
            : null,
        filled: true,
        fillColor: AppColors.lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.025),
          borderSide: BorderSide(color: AppColors.mediumGrey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.025),
          borderSide: BorderSide(
            color: AppColors.mediumGrey.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.025),
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.016,
        ),
      ),
    );
  }
}