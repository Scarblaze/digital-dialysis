// lib/pages/doctor/dialysis_session_detail_page.dart

import 'package:digitaldailysis/controllers/doctor_material_controller.dart';
import 'package:digitaldailysis/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DialysisSessionDetailPage extends StatefulWidget {
  final dynamic session;
  final int sessionNumber;
  final String materialSessionId;


  const DialysisSessionDetailPage({
    super.key,
    required this.session,
    required this.sessionNumber,
    required this.materialSessionId,
  });

  @override
  State<DialysisSessionDetailPage> createState() => _DialysisSessionDetailPageState();
}

class _DialysisSessionDetailPageState extends State<DialysisSessionDetailPage> {
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final controller = Get.find<DoctorMaterialController>();
    final readings = widget.session?.parameters?.readings;
    final verifiedAt = widget.session.verifiedAt;
    final verificationNotes = widget.session.verificationNotes;
    final materials = widget.session?.materials?.pdMaterials;


    final status = widget.session.status ?? 'unknown';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final completedAt = widget.session.completedAt;
    final parameters = widget.session?.parameters;
    final voluntary = parameters?.voluntary;
    final images = widget.session.images ?? [];

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: CustomScrollView(
        slivers: [
          // ================= HEADER =================
          SliverAppBar(
            pinned: true,
            expandedHeight: h * 0.26,
            backgroundColor: statusColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: EdgeInsets.all(w * 0.05),
                alignment: Alignment.bottomLeft,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withValues(alpha: 0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(w * 0.035),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(w * 0.035),
                      ),
                      child: Icon(
                        statusIcon,
                        color: Colors.white,
                        size: w * 0.085,
                      ),
                    ),
                    SizedBox(height: h * 0.015),
                    Text(
                      'Dialysis Session ${widget.sessionNumber}',
                      style: TextStyle(
                        fontSize: w * 0.06,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: h * 0.008),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.03,
                        vertical: h * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(w * 0.04),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: w * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    if (completedAt != null) ...[
                      SizedBox(height: h * 0.012),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              color: Colors.white, size: w * 0.04),
                          SizedBox(width: w * 0.015),
                          Text(
                            'Completed: ${_formatDateBeautiful(completedAt)}',
                            style: TextStyle(
                              fontSize: w * 0.036,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ================= BODY =================
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(w * 0.045),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session Info Card
                  _buildSessionInfoCard(w, h, status, completedAt, statusColor),

                  SizedBox(height: h * 0.025),
                  if (status.toLowerCase() == 'verified') ...[
                    SizedBox(height: h * 0.025),
                    _buildVerificationCard(w, h, verifiedAt, verificationNotes),
                  ],


                  // Parameters Section
                  if (voluntary != null) ...[
                    _buildSectionTitle(
                      'Patient Parameters',
                      Icons.assignment,
                      Colors.indigo,
                      w,
                    ),
                    SizedBox(height: h * 0.015),
                    _buildParametersSection(w, h, voluntary),
                    SizedBox(height: h * 0.025),
                  ],

                  // Images Section
                  if (images.isNotEmpty) ...[
                    _buildSectionTitle(
                      'Session Images',
                      Icons.photo_library,
                      Colors.orange,
                      w,
                    ),
                    SizedBox(height: h * 0.015),
                    _buildImagesSection(w, h, images),
                    SizedBox(height: h * 0.025),
                  ],

                  // Verify Button (only show if status is not verified)
                  if (status.toLowerCase() != 'verified') ...[
                    SizedBox(height: h * 0.02),
                    Obx(() {
                      final isLoading = controller.isVerifying.value;
                      return Container(
                        width: double.infinity,
                        height: h * 0.065,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.green.shade700],
                          ),
                          borderRadius: BorderRadius.circular(w * 0.04),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isLoading
                                ? null
                                : () {
                              Get.bottomSheet(
                                _buildVerifySection(w, h),
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                              );
                            },
                            borderRadius: BorderRadius.circular(w * 0.04),
                            child: Center(
                              child: isLoading
                                  ? SizedBox(
                                width: w * 0.06,
                                height: w * 0.06,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_user,
                                      color: Colors.white, size: w * 0.06),
                                  SizedBox(width: w * 0.02),
                                  Text(
                                    'Verify Session',
                                    style: TextStyle(
                                      fontSize: w * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],

                  SizedBox(height: h * 0.03),
                  if (readings != null) ...[
                    _buildSectionTitle(
                      'Dialysis Readings',
                      Icons.monitor_heart,
                      Colors.deepPurple,
                      w,
                    ),
                    SizedBox(height: h * 0.015),
                    _buildReadingsSection(w, h, readings),
                    SizedBox(height: h * 0.025),
                  ],
                  if (materials != null) ...[
                    _buildSectionTitle(
                      'Dialysis Materials Used',
                      Icons.medical_services,
                      Colors.brown,
                      w,
                    ),
                    SizedBox(height: h * 0.015),
                    _buildMaterialsSection(w, h, materials),
                    SizedBox(height: h * 0.025),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsSection(double w, double h, dynamic materials) {
    return _buildParameterCard(
      'PD Fluids & Consumables',
      Icons.water_drop,
      Colors.brown,
      w,
      h,
      [
        _buildParameterItem('1.5% 2L', '${materials.capd.fluid1_5_2L}', w),
        _buildParameterItem('2.5% 2L', '${materials.capd.fluid2_5_2L}', w),
        _buildParameterItem('4.25% 2L', '${materials.capd.fluid4_25_2L}', w),
        _buildParameterItem('Icodextrin 2L', '${materials.icodextrin2L}', w),
        _buildParameterItem('Transfer Set', '${materials.transferSet}', w),
        _buildParameterItem('Minicap', '${materials.minicap}', w),
      ],
    );
  }

  Widget _buildReadingsSection(double w, double h, dynamic readings) {
    return _buildParameterCard(
      'Machine Readings',
      Icons.speed,
      Colors.deepPurple,
      w,
      h,
      [
        _buildParameterItem('Fill Volume', '${readings.fillVolume} L', w),
        _buildParameterItem('Drain Volume', '${readings.drainVolume} L', w),
        _buildParameterItem('Fill Time', '${readings.fillTime} min', w),
        _buildParameterItem('Drain Time', '${readings.drainTime} min', w),
      ],
    );
  }

  Widget _buildVerificationCard(double w, double h, DateTime? verifiedAt, String? notes) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: Colors.green, size: w * 0.06),
              SizedBox(width: w * 0.02),
              Text(
                'Doctor Verification',
                style: TextStyle(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.015),
          if (verifiedAt != null)
            _buildInfoRow('Verified At', _formatDateBeautiful(verifiedAt), w),
          if (notes != null && notes.isNotEmpty) ...[
            SizedBox(height: h * 0.015),
            Text(
              'Doctor Notes',
              style: TextStyle(
                fontSize: w * 0.038,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: h * 0.01),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(w * 0.03),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(w * 0.02),
              ),
              child: Text(
                notes,
                style: TextStyle(fontSize: w * 0.038),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerifySection(double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withValues(alpha: 0.08), Colors.purple.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(w * 0.025),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(w * 0.02),
                ),
                child: Icon(Icons.verified_user, color: Colors.blue[700], size: w * 0.06),
              ),
              SizedBox(width: w * 0.025),
              Text(
                'Doctor Verification',
                style: TextStyle(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.02),
          Text(
            'Verification Note',
            style: TextStyle(
              fontSize: w * 0.038,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: h * 0.01),
          TextField(
            controller: noteController,
            maxLines: 4,
            style: TextStyle(fontSize: w * 0.038),
            decoration: InputDecoration(
              hintText: "Enter your verification notes here...",
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.03),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.03),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.03),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: EdgeInsets.all(w * 0.04),
            ),
          ),
          SizedBox(height: h * 0.02),
          SizedBox(
            width: double.infinity,
            height: h * 0.06,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (noteController.text.trim().isEmpty) {
                  Get.snackbar(
                    "Note Required",
                    "Please add verification note before proceeding",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                    icon: Icon(Icons.warning, color: Colors.white),
                    borderRadius: 12,
                    margin: EdgeInsets.all(w * 0.04),
                  );
                  return;
                }

                // Call verification
                final id = await Get.find<DoctorMaterialController>().verifyDialysisSession(
                  sessionId: widget.session.sessionId!,
                  notes: noteController.text.trim(),
                );
                if(id != null)
                {
                  Get.back(result : true);

                  Get.snackbar(
                    "Success",
                    "Session verified successfully",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.darkPrimary,
                    colorText: Colors.white,
                    icon: Icon(Icons.check_circle, color: Colors.white),
                    borderRadius: 12,
                    margin: EdgeInsets.all(w * 0.04),
                    duration: Duration(seconds: 2),
                  );

                }
                else
                {
                  Get.snackbar(
                    "Error",
                    "Error in verifying Session",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                    icon: Icon(Icons.error, color: Colors.white),
                    borderRadius: 12,
                    margin: EdgeInsets.all(w * 0.04),
                    duration: Duration(seconds: 2),
                  );
                }



                // Show success message


                // Go back to previous screen immediately


              },
              icon: Icon(Icons.verified, size: w * 0.05),
              label: Text(
                "Verify Session",
                style: TextStyle(
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.03),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfoCard(
      double w, double h, String status, dynamic completedAt, Color statusColor) {
    return Container(
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: statusColor, size: w * 0.06),
              SizedBox(width: w * 0.02),
              Text(
                'Session Information',
                style: TextStyle(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.02),
          _buildInfoRow('Session ID', widget.session.sessionId ?? 'N/A', w),
          Divider(height: h * 0.03),
          _buildInfoRow('Status', status.toUpperCase(), w,
              valueColor: statusColor),
          if (completedAt != null) ...[
            Divider(height: h * 0.03),
            _buildInfoRow(
                'Completed At', _formatDateBeautiful(completedAt), w),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, double w,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: w * 0.038,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: w * 0.038,
              color: valueColor ?? Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color, double w) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(w * 0.025),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(w * 0.03),
          ),
          child: Icon(icon, color: color, size: w * 0.055),
        ),
        SizedBox(width: w * 0.025),
        Text(
          title,
          style: TextStyle(
            fontSize: w * 0.05,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildParametersSection(double w, double h, dynamic voluntary) {
    return Column(
      children: [
        // Wellbeing & Vital Signs
        _buildParameterCard(
          'Wellbeing & Vital Signs',
          Icons.favorite,
          Colors.red,
          w,
          h,
          [
            _buildParameterItem('Wellbeing Score', '${voluntary.wellbeing}/10', w),
            _buildParameterItem('Sleep Quality', '${voluntary.sleepQuality}/10', w),
            if (voluntary.bpMeasured == true)
              _buildParameterItem('Blood Pressure',
                  '${voluntary.sbp}/${voluntary.dbp} mmHg', w),
            if (voluntary.weightMeasured == true)
              _buildParameterItem('Weight', '${voluntary.weightKg} kg', w),
          ],
        ),

        SizedBox(height: h * 0.015),

        // Symptoms
        _buildParameterCard(
          'Symptoms',
          Icons.medical_information,
          Colors.blue,
          w,
          h,
          [
            _buildBooleanParameter('Appetite', voluntary.appetite, w),
            _buildBooleanParameter('Nausea', voluntary.nausea, w),
            _buildBooleanParameter('Vomiting', voluntary.vomiting, w),
            _buildBooleanParameter('Abdominal Discomfort',
                voluntary.abdominalDiscomfort, w),
            _buildBooleanParameter('Constipation', voluntary.constipation, w),
            _buildBooleanParameter('Diarrhea', voluntary.diarrhea, w),
            _buildBooleanParameter('Fatigue', voluntary.fatigue, w),
            _buildBooleanParameter('Breathlessness', voluntary.breathlessness, w),
            _buildBooleanParameter('Foot Swelling', voluntary.footSwelling, w),
            _buildBooleanParameter('Facial Puffiness', voluntary.facialPuffiness, w),
            _buildBooleanParameter('Fever', voluntary.fever, w),
            _buildBooleanParameter('Chills', voluntary.chills, w),
          ],
        ),

        SizedBox(height: h * 0.015),

        // Dialysis Details
        _buildParameterCard(
          'Dialysis Details',
          Icons.water_drop,
          Colors.teal,
          w,
          h,
          [
            _buildBooleanParameter(
                'Able to Do Activities', voluntary.ableToDoActivities, w),
            _buildBooleanParameter(
                'Pain During Fill/Drain', voluntary.painDuringFillDrain, w),
            _buildBooleanParameter('Slow Drain', voluntary.slowDrain, w),
            _buildBooleanParameter('Catheter Leak', voluntary.catheterLeak, w),
            _buildBooleanParameter(
                'Exit Site Issue', voluntary.exitSiteIssue, w),
            _buildParameterItem(
                'Effluent Clarity', voluntary.effluentClarity ?? 'N/A', w),
          ],
        ),

        SizedBox(height: h * 0.015),

        // Urine & Other
        _buildParameterCard(
          'Urine & Other Observations',
          Icons.opacity,
          Colors.amber,
          w,
          h,
          [
            _buildBooleanParameter('Urine Passed', voluntary.urinePassed, w),
            if (voluntary.urinePassed == true)
              _buildParameterItem(
                  'Urine Amount', voluntary.urineAmount ?? 'N/A', w),
            _buildBooleanParameter('Rapid Weight Gain', voluntary.rapidWeightGain, w),
            _buildBooleanParameter(
                'Fluid Overload Feeling', voluntary.fluidOverloadFeeling, w),
            _buildBooleanParameter(
                'New Abdominal Pain', voluntary.newAbdominalPain, w),
            _buildBooleanParameter('Sudden Unwell', voluntary.suddenUnwell, w),
          ],
        ),

        SizedBox(height: h * 0.015),

        // Comments
        if (voluntary.comments != null && voluntary.comments.isNotEmpty)
          _buildCommentsCard(voluntary.comments, w, h),
      ],
    );
  }

  Widget _buildParameterCard(
      String title,
      IconData icon,
      Color color,
      double w,
      double h,
      List<Widget> children,
      ) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(w * 0.02),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(w * 0.02),
                ),
                child: Icon(icon, color: color, size: w * 0.05),
              ),
              SizedBox(width: w * 0.02),
              Text(
                title,
                style: TextStyle(
                  fontSize: w * 0.042,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.015),
          ...children,
        ],
      ),
    );
  }

  Widget _buildParameterItem(String label, String value, double w) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: w * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: w * 0.036,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: w * 0.038,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanParameter(String label, bool? value, double w) {
    final isPositive = value == true;
    final color = isPositive ? Colors.green : Colors.grey;
    final icon = isPositive ? Icons.check_circle : Icons.cancel;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: w * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: w * 0.036,
                color: Colors.grey[700],
              ),
            ),
          ),
          Row(
            children: [
              Icon(icon, color: color, size: w * 0.045),
              SizedBox(width: w * 0.015),
              Text(
                isPositive ? 'Yes' : 'No',
                style: TextStyle(
                  fontSize: w * 0.036,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsCard(String comments, double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(w * 0.02),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(w * 0.02),
                ),
                child: Icon(Icons.comment, color: Colors.purple, size: w * 0.05),
              ),
              SizedBox(width: w * 0.02),
              Text(
                'Comments',
                style: TextStyle(
                  fontSize: w * 0.042,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.015),
          Container(
            padding: EdgeInsets.all(w * 0.035),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(w * 0.025),
            ),
            child: Text(
              comments,
              style: TextStyle(
                fontSize: w * 0.038,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection(double w, double h, List<dynamic> images) {
    return Container(
      height: h * 0.22,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => SizedBox(width: w * 0.03),
        itemBuilder: (_, i) {
          final img = images[i];
          final imageUrl = img.imageUrl ?? img.toString();
          return GestureDetector(
            onTap: () => _showImageDialog(imageUrl, i, w, h),
            child: Hero(
              tag: 'dialysis_session_image_$i',
              child: Container(
                width: w * 0.65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(w * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(w * 0.04),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(imageUrl, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4)
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: w * 0.03,
                        right: w * 0.03,
                        child: Container(
                          padding: EdgeInsets.all(w * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(w * 0.02),
                          ),
                          child: Icon(Icons.zoom_in, size: w * 0.05),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageDialog(String imageUrl, int index, double w, double h) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black87,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Hero(
                  tag: 'dialysis_session_image_$index',
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: h * 0.02,
              right: w * 0.02,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateBeautiful(DateTime date) {
    final local = date.toLocal();
    return DateFormat('d MMM yyyy, h:mm a').format(local);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.orangeAccent;
      case 'completed':
        return Colors.blue;
      case 'pending':
        return Colors.grey;
      case 'verified':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'acknowledged':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.play_circle;
      case 'verified':
        return Icons.verified;
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      case 'acknowledged':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }
}