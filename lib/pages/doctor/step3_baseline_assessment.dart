// lib/pages/doctor/step3_baseline_assessment.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:digitaldailysis/controllers/patient_registration_controller.dart';
import 'package:digitaldailysis/utils/colors.dart';

class Step3BaselineAssessment extends StatefulWidget {
  final PatientRegistrationController controller;

  const Step3BaselineAssessment({super.key, required this.controller});

  @override
  State<Step3BaselineAssessment> createState() => _Step3BaselineAssessmentState();
}

class _Step3BaselineAssessmentState extends State<Step3BaselineAssessment> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context, Rx<DateTime?> dateController, String label) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateController.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.darkPrimary,
              onPrimary: Colors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dateController.value = picked;
    }
  }

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
              "Step 3: Baseline Assessment",
              style: TextStyle(
                fontSize: w * 0.055,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: h * 0.01),
            Text(
              "Complete baseline medical assessment",
              style: TextStyle(
                fontSize: w * 0.038,
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: h * 0.03),

            // PD Catheter & Training Section
            _buildSectionHeader("PD Catheter & Training", w),
            SizedBox(height: h * 0.02),

            Obx(() => _buildDateField(
              context,
              "Catheter Insertion Date",
              widget.controller.catheterInsertionDate,
              w,
              h,
            )),
            SizedBox(height: h * 0.02),

            Obx(() => DropdownButtonFormField<String>(
              key: ValueKey(widget.controller.selectedCatheterTechnique.value),
              initialValue: widget.controller.selectedCatheterTechnique.value,
              decoration: _inputDecoration(
                label: "Catheter Technique",
                icon: Icons.construction,
                w: w,
              ),
              items: ['Surgical', 'Percutaneous', 'Laparoscopic']
                  .map((tech) => DropdownMenuItem(
                value: tech,
                child: Text(tech),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.controller.selectedCatheterTechnique.value = value;
                }
              },
            )),
            SizedBox(height: h * 0.02),

            Obx(() => _buildDateField(
              context,
              "PD Start Date",
              widget.controller.pdStartDate,
              w,
              h,
            )),
            SizedBox(height: h * 0.02),

            Obx(() => _buildDateField(
              context,
              "Training Start Date",
              widget.controller.trainingStartDate,
              w,
              h,
            )),
            SizedBox(height: h * 0.02),

            Obx(() => _buildDateField(
              context,
              "Training Completion Date",
              widget.controller.trainingCompletionDate,
              w,
              h,
            )),
            SizedBox(height: h * 0.03),

            // Complications Section
            _buildSectionHeader("Peri-Implant Complications", w),
            SizedBox(height: h * 0.02),

            Obx(() => CheckboxListTile(
              title: Text(
                "Complications Present",
                style: TextStyle(fontSize: w * 0.04),
              ),
              value: widget.controller.hasComplications.value,
              onChanged: (value) {
                widget.controller.hasComplications.value = value ?? false;
              },
              activeColor: AppColors.darkPrimary,
              contentPadding: EdgeInsets.zero,
            )),
            SizedBox(height: h * 0.01),

            Obx(() => widget.controller.hasComplications.value
                ? TextFormField(
              controller: widget.controller.complicationsDetailsController,
              maxLines: 3,
              decoration: _inputDecoration(
                label: "Complication Details",
                icon: Icons.notes,
                w: w,
              ),
            )
                : const SizedBox()),
            SizedBox(height: h * 0.03),

            // Clinical Examination Section
            _buildSectionHeader("Clinical Examination", w),
            SizedBox(height: h * 0.02),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.controller.pulseController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: "Pulse (bpm)",
                      icon: Icons.favorite_outline,
                      w: w,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                  ),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: TextFormField(
                    controller: widget.controller.weightController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: "Weight (kg)",
                      icon: Icons.monitor_weight_outlined,
                      w: w,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.controller.bpSystolicController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: "BP Systolic",
                      icon: Icons.bloodtype_outlined,
                      w: w,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                  ),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: TextFormField(
                    controller: widget.controller.bpDiastolicController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: "BP Diastolic",
                      icon: Icons.bloodtype_outlined,
                      w: w,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.heightController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                label: "Height (cm)",
                icon: Icons.height,
                w: w,
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Required" : null,
            ),
            SizedBox(height: h * 0.02),

            // Clinical Signs Checkboxes
            Text(
              "Clinical Signs",
              style: TextStyle(
                fontSize: w * 0.04,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: h * 0.01),

            Wrap(
              spacing: w * 0.02,
              runSpacing: h * 0.01,
              children: [
                Obx(() => _buildCheckboxChip(
                  "Pallor",
                  widget.controller.hasPallor,
                  w,
                )),
                Obx(() => _buildCheckboxChip(
                  "Icterus",
                  widget.controller.hasIcterus,
                  w,
                )),
                Obx(() => _buildCheckboxChip(
                  "Cyanosis",
                  widget.controller.hasCyanosis,
                  w,
                )),
                Obx(() => _buildCheckboxChip(
                  "Clubbing",
                  widget.controller.hasClubbing,
                  w,
                )),
                Obx(() => _buildCheckboxChip(
                  "Edema",
                  widget.controller.hasEdema,
                  w,
                )),
              ],
            ),
            SizedBox(height: h * 0.03),

            // PD Prescription Section
            _buildSectionHeader("PD Prescription", w),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.dwellTimingController,
              decoration: _inputDecoration(
                label: "Dwell Timing (e.g., Morning)",
                icon: Icons.access_time,
                w: w,
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Required" : null,
            ),
            SizedBox(height: h * 0.02),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.controller.solutionStrengthController,
                    decoration: _inputDecoration(
                      label: "Solution %",
                      icon: Icons.water_drop,
                      w: w,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                  ),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: TextFormField(
                    controller: widget.controller.fillVolumeController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: "Volume (ml)",
                      icon: Icons.local_drink_outlined,
                      w: w,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.controller.dwellDurationController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: "Duration (hrs)",
                      icon: Icons.timer_outlined,
                      w: w,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                  ),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: TextFormField(
                    controller: widget.controller.numberOfExchangesController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: "Exchanges",
                      icon: Icons.repeat,
                      w: w,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),

            Obx(() => CheckboxListTile(
              title: Text(
                "Icodextrin Used",
                style: TextStyle(fontSize: w * 0.04),
              ),
              value: widget.controller.icodextrinUsed.value,
              onChanged: (value) {
                widget.controller.icodextrinUsed.value = value ?? false;
              },
              activeColor: AppColors.darkPrimary,
              contentPadding: EdgeInsets.zero,
            )),
            SizedBox(height: h * 0.03),

            // Laboratory Results Section
            _buildSectionHeader("Laboratory Results", w),
            SizedBox(height: h * 0.02),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: widget.controller.hemoglobinController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: "Hemoglobin",
                      icon: Icons.bloodtype,
                      w: w,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                  ),
                ),
                SizedBox(width: w * 0.02),
                Expanded(
                  flex: 3,
                  child: Obx(() => _buildDateFieldCompact(
                    context,
                    "Date",
                    widget.controller.hemoglobinDate,
                    w,
                    h,
                  )),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: widget.controller.ureaController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: "Urea",
                      icon: Icons.science_outlined,
                      w: w,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                  ),
                ),
                SizedBox(width: w * 0.02),
                Expanded(
                  flex: 3,
                  child: Obx(() => _buildDateFieldCompact(
                    context,
                    "Date",
                    widget.controller.ureaDate,
                    w,
                    h,
                  )),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: widget.controller.creatinineController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: "Creatinine",
                      icon: Icons.local_hospital_outlined,
                      w: w,
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                  ),
                ),
                SizedBox(width: w * 0.02),
                Expanded(
                  flex: 3,
                  child: Obx(() => _buildDateFieldCompact(
                    context,
                    "Date",
                    widget.controller.creatinineDate,
                    w,
                    h,
                  )),
                ),
              ],
            ),
            SizedBox(height: h * 0.03),

            // Plan & Advice Section
            _buildSectionHeader("Plan & Advice", w),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.advisedPrescriptionController,
              maxLines: 2,
              decoration: _inputDecoration(
                label: "Advised Prescription",
                icon: Icons.note_alt_outlined,
                w: w,
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Required" : null,
            ),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.medicationsController,
              maxLines: 2,
              decoration: _inputDecoration(
                label: "Medications",
                icon: Icons.medication_outlined,
                w: w,
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Required" : null,
            ),
            SizedBox(height: h * 0.02),

            TextFormField(
              controller: widget.controller.followUpController,
              maxLines: 2,
              decoration: _inputDecoration(
                label: "Follow-up Instructions",
                icon: Icons.calendar_month_outlined,
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
                        await widget.controller.createBaselineAssessment();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: h * 0.02),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(w * 0.03),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.white),
                        SizedBox(width: w * 0.02),
                        Text(
                          "Complete Registration",
                          style: TextStyle(
                            fontSize: w * 0.04,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  )),
                ),
              ],
            ),
            SizedBox(height: h * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context,
      String label,
      Rx<DateTime?> dateController,
      double w,
      double h,
      ) {
    return InkWell(
      onTap: () => _selectDate(context, dateController, label),
      child: InputDecorator(
        decoration: _inputDecoration(
          label: label,
          icon: Icons.calendar_today,
          w: w,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateController.value != null
                  ? DateFormat('dd MMM yyyy').format(dateController.value!)
                  : 'Select Date',
              style: TextStyle(
                fontSize: w * 0.04,
                color: dateController.value != null
                    ? AppColors.black
                    : AppColors.darkGrey,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.darkPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFieldCompact(
      BuildContext context,
      String label,
      Rx<DateTime?> dateController,
      double w,
      double h,
      ) {
    return InkWell(
      onTap: () => _selectDate(context, dateController, label),
      child: InputDecorator(
        decoration: _inputDecoration(
          label: label,
          icon: Icons.calendar_today,
          w: w,
        ),
        child: Text(
          dateController.value != null
              ? DateFormat('dd/MM/yy').format(dateController.value!)
              : 'Date',
          style: TextStyle(
            fontSize: w * 0.035,
            color: dateController.value != null
                ? AppColors.black
                : AppColors.darkGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxChip(String label, RxBool value, double w) {
    return FilterChip(
      label: Text(label),
      selected: value.value,
      onSelected: (selected) {
        value.value = selected;
      },
      selectedColor: AppColors.darkPrimary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.darkPrimary,
      labelStyle: TextStyle(
        fontSize: w * 0.035,
        color: value.value ? AppColors.darkPrimary : AppColors.black,
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
      contentPadding: EdgeInsets.symmetric(
        horizontal: w * 0.04,
        vertical: w * 0.04,
      ),
    );
  }
}