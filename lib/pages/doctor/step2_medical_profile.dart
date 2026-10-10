// lib/pages/doctor/step2_medical_profile.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/controllers/patient_registration_controller.dart';
import 'package:digitaldailysis/utils/colors.dart';

class Step2MedicalProfile extends StatefulWidget {
  final PatientRegistrationController controller;

  const Step2MedicalProfile({super.key, required this.controller});

  @override
  State<Step2MedicalProfile> createState() => _Step2MedicalProfileState();
}

class _Step2MedicalProfileState extends State<Step2MedicalProfile> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: EdgeInsets.all(w * 0.05),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Step 2: Medical Profile",
              style: TextStyle(
                fontSize: w * 0.055,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: h * 0.01),
            Text(
              "Complete patient's medical information",
              style: TextStyle(
                fontSize: w * 0.038,
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: h * 0.03),

            // Demographics Section
            _buildSectionHeader("Demographics", w),
            SizedBox(height: h * 0.02),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.controller.ageController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: "Age",
                      icon: Icons.calendar_today,
                      w: w,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                  ),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                    key: ValueKey(widget.controller.selectedGender.value),
                    initialValue: widget.controller.selectedGender.value,
                    decoration: _inputDecoration(
                      label: "Gender",
                      icon: Icons.person,
                      w: w,
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        widget.controller.selectedGender.value = value;
                      }
                    },
                  )),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.crNumberController,
              decoration: _inputDecoration(
                label: "CR Number",
                icon: Icons.badge_outlined,
                w: w,
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Required" : null,
            ),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.contactNumberController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                label: "Contact Number",
                icon: Icons.phone,
                w: w,
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Required" : null,
            ),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.addressController,
              maxLines: 2,
              decoration: _inputDecoration(
                label: "Address",
                icon: Icons.location_on_outlined,
                w: w,
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Required" : null,
            ),
            SizedBox(height: h * 0.02),

            Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                    key: ValueKey(widget.controller.selectedEducation.value),
                    initialValue: widget.controller.selectedEducation.value,
                    decoration: _inputDecoration(
                      label: "Education",
                      icon: Icons.school,
                      w: w,
                    ),
                    items: [
                      'No formal education',
                      'Primary',
                      'Secondary',
                      'Graduate',
                      'Post-graduate'
                    ]
                        .map((edu) => DropdownMenuItem(
                      value: edu,
                      child: Text(edu, style: TextStyle(fontSize: w * 0.035)),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        widget.controller.selectedEducation.value = value;
                      }
                    },
                  )),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                    key: ValueKey(widget.controller.selectedIncome.value),
                    initialValue: widget.controller.selectedIncome.value,
                    decoration: _inputDecoration(
                      label: "Income",
                      icon: Icons.attach_money,
                      w: w,
                    ),
                    items: [
                      'Below poverty line',
                      'Lower middle',
                      'Middle',
                      'Upper middle',
                      'High'
                    ]
                        .map((income) => DropdownMenuItem(
                      value: income,
                      child: Text(income, style: TextStyle(fontSize: w * 0.035)),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        widget.controller.selectedIncome.value = value;
                      }
                    },
                  )),
                ),
              ],
            ),
            SizedBox(height: h * 0.03),

            // Medical Information Section
            _buildSectionHeader("Medical Information", w),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.primaryDiagnosisController,
              decoration: _inputDecoration(
                label: "Primary Diagnosis",
                icon: Icons.medical_information_outlined,
                w: w,
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Required" : null,
            ),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.nativeKidneyDiseaseController,
              decoration: _inputDecoration(
                label: "Native Kidney Disease",
                icon: Icons.health_and_safety_outlined,
                w: w,
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Required" : null,
            ),
            SizedBox(height: h * 0.02),

            Obx(() => DropdownButtonFormField<String>(
              key: ValueKey(widget.controller.selectedDialysisType.value),
              initialValue: widget.controller.selectedDialysisType.value,
              decoration: _inputDecoration(
                label: "Dialysis Type",
                icon: Icons.water_drop_outlined,
                w: w,
              ),
              items: ['PD', 'HD']
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.controller.selectedDialysisType.value = value;
                }
              },
            )),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.allergiesController,
              maxLines: 2,
              decoration: _inputDecoration(
                label: "Allergies (comma separated)",
                icon: Icons.warning_amber_outlined,
                w: w,
              ),
            ),
            SizedBox(height: h * 0.03),

            // Emergency Contact Section
            _buildSectionHeader("Emergency Contact", w),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.emergencyNameController,
              decoration: _inputDecoration(
                label: "Contact Name",
                icon: Icons.person_outline,
                w: w,
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Required" : null,
            ),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.emergencyPhoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                label: "Contact Phone",
                icon: Icons.phone,
                w: w,
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Required" : null,
            ),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.emergencyRelationController,
              decoration: _inputDecoration(
                label: "Relation",
                icon: Icons.family_restroom,
                w: w,
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Required" : null,
            ),
            SizedBox(height: h * 0.05),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.controller.previousStep();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: h * 0.02),
                      side: BorderSide(color: AppColors.darkPrimary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(w * 0.03),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, color: AppColors.darkPrimary),
                        SizedBox(width: w * 0.02),
                        Text(
                          "Back",
                          style: TextStyle(
                            fontSize: w * 0.04,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  flex: 2,
                  child: Obx(() => widget.controller.isLoading.value
                      ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.darkPrimary,
                    ),
                  )
                      : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await widget.controller.createMedicalProfile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: h * 0.02),
                      backgroundColor: AppColors.darkPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(w * 0.03),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Next: Assessment",
                          style: TextStyle(
                            fontSize: w * 0.04,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: w * 0.02),
                        Icon(Icons.arrow_forward, color: AppColors.white),
                      ],
                    ),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, double w) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: w * 0.025, horizontal: w * 0.03),
      decoration: BoxDecoration(
        color: AppColors.darkPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(w * 0.02),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: w * 0.05,
            decoration: BoxDecoration(
              color: AppColors.darkPrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: w * 0.02),
          Text(
            title,
            style: TextStyle(
              fontSize: w * 0.045,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPrimary,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required double w,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: AppColors.darkPrimary,
        size: w * 0.055,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(w * 0.03),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(w * 0.03),
        borderSide: BorderSide(
          color: AppColors.darkPrimary,
          width: 2,
        ),
      ),
    );
  }
}