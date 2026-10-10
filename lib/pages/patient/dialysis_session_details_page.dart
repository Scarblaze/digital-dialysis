// lib/pages/patient/dialysis_session_details_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:digitaldailysis/utils/colors.dart';
import 'package:digitaldailysis/models/patient/patient_info_model.dart';

class DialysisSessionDetailsPage extends StatelessWidget {
  final DialysisSession session;
  final int sessionNumber;

  const DialysisSessionDetailsPage({
    super.key,
    required this.session,
    required this.sessionNumber,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final params = session.parameters?.voluntary;
    final hasData = params != null;

    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.darkPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Session $sessionNumber Details",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: w * 0.045,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Card
            _buildStatusHeader(w, h),

            SizedBox(height: h * 0.02),

            if (!hasData || params.comments?.isEmpty == true)
              _buildNoDataCard(w, h)
            else ...[
              // General Well-being
              if (params.wellbeing != null)
                _buildWellbeingCard(params, w, h),

              SizedBox(height: h * 0.02),

              // Gastrointestinal Symptoms
              _buildGastrointestinalCard(params, w, h),

              SizedBox(height: h * 0.02),

              // Energy & Sleep
              if (params.sleepQuality != null)
                _buildEnergyCard(params, w, h),

              SizedBox(height: h * 0.02),

              // Fluid Status
              _buildFluidStatusCard(params, w, h),

              SizedBox(height: h * 0.02),

              // Vital Signs
              if (params.bpMeasured == true || params.weightMeasured == true)
                _buildVitalsCard(params, w, h),

              SizedBox(height: h * 0.02),

              // Dialysis-Specific Issues
              _buildDialysisIssuesCard(params, w, h),

              SizedBox(height: h * 0.02),

              // Urine Output
              _buildUrineOutputCard(params, w, h),

              SizedBox(height: h * 0.02),

              // Warning Signs
              if (_hasWarningSignsData(params))
                _buildWarningSignsCard(params, w, h),

              SizedBox(height: h * 0.02),

              // Comments
              if (params.comments != null && params.comments!.isNotEmpty)
                _buildCommentsCard(params, w, h),

              SizedBox(height: h * 0.02),

              // Images
              if (session.images.isNotEmpty)
                _buildImagesCard(w, h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(double w, double h) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (session.status) {
      case "verified":
        statusColor = AppStatusColors.verified;
        statusIcon = Icons.verified;
        statusText = "Verified by Doctor";
        break;
      case "completed":
        statusColor = AppStatusColors.info;
        statusIcon = Icons.check_circle;
        statusText = "Awaiting Verification";
        break;
      case "active":
        statusColor = AppStatusColors.active;
        statusIcon = Icons.pending;
        statusText = "In Progress";
        break;
      default:
        statusColor = AppStatusColors.pending;
        statusIcon = Icons.hourglass_empty;
        statusText = "Pending";
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(w * 0.025),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: Colors.white, size: w * 0.08),
              ),
              SizedBox(width: w * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Session $sessionNumber",
                      style: TextStyle(
                        fontSize: w * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: w * 0.038,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (session.completedAt != null) ...[
            SizedBox(height: h * 0.02),
            Divider(color: Colors.white.withValues(alpha: 0.3)),
            SizedBox(height: h * 0.01),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.white, size: w * 0.045),
                SizedBox(width: w * 0.02),
                Text(
                  "Completed: ${_formatDate(session.completedAt!)}",
                  style: TextStyle(
                    fontSize: w * 0.035,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoDataCard(double w, double h) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.06),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: w * 0.15,
              color: AppColors.mediumGrey,
            ),
            SizedBox(height: h * 0.02),
            Text(
              "No Health Data Available",
              style: TextStyle(
                fontSize: w * 0.042,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: h * 0.01),
            Text(
              "This session was completed without detailed health tracking",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: w * 0.035,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellbeingCard(VoluntaryParameters params, double w, double h) {
    return _buildSectionCard(
      title: "General Well-being",
      icon: Icons.mood,
      color: AppStatusColors.success,
      w: w,
      h: h,
      child: Column(
        children: [
          _buildScoreDisplay(
            "Overall Feeling",
            params.wellbeing!,
            10,
            w,
            h,
          ),
        ],
      ),
    );
  }

  Widget _buildGastrointestinalCard(
      VoluntaryParameters params, double w, double h) {
    return _buildSectionCard(
      title: "Gastrointestinal Symptoms",
      icon: Icons.restaurant,
      color: AppStatusColors.info,
      w: w,
      h: h,
      child: Wrap(
        spacing: w * 0.02,
        runSpacing: h * 0.01,
        children: [
          _buildStatusChip("Appetite", params.appetite, w),
          _buildStatusChip("Nausea", params.nausea, w, isNegative: true),
          _buildStatusChip("Vomiting", params.vomiting, w, isNegative: true),
          _buildStatusChip("Abdominal Discomfort", params.abdominalDiscomfort,
              w, isNegative: true),
          _buildStatusChip("Constipation", params.constipation, w,
              isNegative: true),
          _buildStatusChip("Diarrhea", params.diarrhea, w, isNegative: true),
        ],
      ),
    );
  }

  Widget _buildEnergyCard(VoluntaryParameters params, double w, double h) {
    return _buildSectionCard(
      title: "Energy & Sleep",
      icon: Icons.bedtime,
      color: AppStatusColors.active,
      w: w,
      h: h,
      child: Column(
        children: [
          _buildScoreDisplay(
            "Sleep Quality",
            params.sleepQuality!,
            10,
            w,
            h,
          ),
          SizedBox(height: h * 0.015),
          Wrap(
            spacing: w * 0.02,
            runSpacing: h * 0.01,
            children: [
              _buildStatusChip("Fatigue", params.fatigue, w, isNegative: true),
              _buildStatusChip(
                  "Able to Do Activities", params.ableToDoActivities, w),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFluidStatusCard(VoluntaryParameters params, double w, double h) {
    return _buildSectionCard(
      title: "Fluid Status",
      icon: Icons.water_drop,
      color: AppStatusColors.warning,
      w: w,
      h: h,
      child: Wrap(
        spacing: w * 0.02,
        runSpacing: h * 0.01,
        children: [
          _buildStatusChip("Breathlessness", params.breathlessness, w,
              isNegative: true),
          _buildStatusChip("Foot Swelling", params.footSwelling, w,
              isNegative: true),
          _buildStatusChip("Facial Puffiness", params.facialPuffiness, w,
              isNegative: true),
          _buildStatusChip("Rapid Weight Gain", params.rapidWeightGain, w,
              isNegative: true),
          _buildStatusChip(
              "Fluid Overload Feeling", params.fluidOverloadFeeling, w,
              isNegative: true),
        ],
      ),
    );
  }

  Widget _buildVitalsCard(VoluntaryParameters params, double w, double h) {
    return _buildSectionCard(
      title: "Vital Signs",
      icon: Icons.monitor_heart,
      color: AppColors.darkPrimary,
      w: w,
      h: h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (params.bpMeasured == true) ...[
            _buildVitalRow(
              "Blood Pressure",
              "${params.sbp ?? 'N/A'}/${params.dbp ?? 'N/A'} mmHg",
              Icons.favorite,
              AppStatusColors.error,
              w,
            ),
            if (params.weightMeasured == true) SizedBox(height: h * 0.015),
          ],
          if (params.weightMeasured == true)
            _buildVitalRow(
              "Weight",
              "${params.weightKg ?? 'N/A'} kg",
              Icons.scale,
              AppStatusColors.info,
              w,
            ),
        ],
      ),
    );
  }

  Widget _buildDialysisIssuesCard(
      VoluntaryParameters params, double w, double h) {
    return _buildSectionCard(
      title: "Dialysis-Specific Issues",
      icon: Icons.medical_services,
      color: AppStatusColors.error,
      w: w,
      h: h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: w * 0.02,
            runSpacing: h * 0.01,
            children: [
              _buildStatusChip("Pain During Fill/Drain",
                  params.painDuringFillDrain, w, isNegative: true),
              _buildStatusChip("Slow Drain", params.slowDrain, w,
                  isNegative: true),
              _buildStatusChip("Catheter Leak", params.catheterLeak, w,
                  isNegative: true),
              _buildStatusChip("Exit Site Issue", params.exitSiteIssue, w,
                  isNegative: true),
            ],
          ),
          if (params.effluentClarity != null) ...[
            SizedBox(height: h * 0.015),
            _buildInfoRow(
              "Effluent Clarity",
              params.effluentClarity!.capitalizeFirst!,
              Icons.opacity,
              w,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUrineOutputCard(VoluntaryParameters params, double w, double h) {
    return _buildSectionCard(
      title: "Urine Output",
      icon: Icons.local_drink,
      color: AppStatusColors.info,
      w: w,
      h: h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            "Urine Passed",
            params.urinePassed == true ? "Yes" : "No",
            Icons.check_circle,
            w,
          ),
          if (params.urinePassed == true && params.urineAmount != null) ...[
            SizedBox(height: h * 0.01),
            _buildInfoRow(
              "Amount",
              params.urineAmount!.capitalizeFirst!,
              Icons.water_drop,
              w,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarningSignsCard(
      VoluntaryParameters params, double w, double h) {
    return _buildSectionCard(
      title: "⚠️ Warning Signs",
      icon: Icons.warning,
      color: Colors.red,
      w: w,
      h: h,
      child: Wrap(
        spacing: w * 0.02,
        runSpacing: h * 0.01,
        children: [
          if (params.fever == true)
            _buildStatusChip("Fever", params.fever, w, isNegative: true),
          if (params.chills == true)
            _buildStatusChip("Chills", params.chills, w, isNegative: true),
          if (params.newAbdominalPain == true)
            _buildStatusChip("New Abdominal Pain", params.newAbdominalPain, w,
                isNegative: true),
          if (params.suddenUnwell == true)
            _buildStatusChip("Suddenly Unwell", params.suddenUnwell, w,
                isNegative: true),
          if (!_hasWarningSignsData(params))
            _buildStatusChip("No Warning Signs", false, w),
        ],
      ),
    );
  }

  Widget _buildCommentsCard(VoluntaryParameters params, double w, double h) {
    return _buildSectionCard(
      title: "Additional Comments",
      icon: Icons.comment,
      color: AppStatusColors.verified,
      w: w,
      h: h,
      child: Container(
        padding: EdgeInsets.all(w * 0.035),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(w * 0.025),
        ),
        child: Text(
          params.comments!,
          style: TextStyle(
            fontSize: w * 0.038,
            color: AppColors.black,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildImagesCard(double w, double h) {
    return _buildSectionCard(
      title: "Session Images",
      icon: Icons.photo_library,
      color: AppStatusColors.info,
      w: w,
      h: h,
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: w * 0.025,
          mainAxisSpacing: w * 0.025,
        ),
        itemCount: session.images.length,
        itemBuilder: (context, index) {
          final imageUrl = session.images[index].imageUrl;
          return ClipRRect(
            borderRadius: BorderRadius.circular(w * 0.03),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.lightGrey,
                  child: Icon(
                    Icons.broken_image,
                    color: AppColors.mediumGrey,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required double w,
    required double h,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.04),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(w * 0.04),
                topRight: Radius.circular(w * 0.04),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(w * 0.02),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(w * 0.02),
                  ),
                  child: Icon(icon, color: color, size: w * 0.055),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: w * 0.042,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(w * 0.04),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(
      String label, int score, int maxScore, double w, double h) {
    final percentage = score / maxScore;
    Color scoreColor;

    if (percentage >= 0.7) {
      scoreColor = AppStatusColors.success;
    } else if (percentage >= 0.4) {
      scoreColor = AppStatusColors.warning;
    } else {
      scoreColor = AppStatusColors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: w * 0.038,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.025,
                vertical: h * 0.005,
              ),
              decoration: BoxDecoration(
                color: scoreColor,
                borderRadius: BorderRadius.circular(w * 0.03),
              ),
              child: Text(
                "$score/$maxScore",
                style: TextStyle(
                  fontSize: w * 0.036,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: h * 0.01),
        ClipRRect(
          borderRadius: BorderRadius.circular(w * 0.01),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            minHeight: h * 0.012,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, bool? value, double w,
      {bool isNegative = false}) {
    final isPresent = value == true;
    final showAsPositive = isNegative ? !isPresent : isPresent;

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: w * 0.032,
          color: showAsPositive ? Colors.green : Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: showAsPositive
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.1),
      avatar: Icon(
        showAsPositive ? Icons.check_circle : Icons.cancel,
        color: showAsPositive ? Colors.green : Colors.grey,
        size: w * 0.04,
      ),
      padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: w * 0.008),
    );
  }

  Widget _buildVitalRow(
      String label, String value, IconData icon, Color color, double w) {
    return Container(
      padding: EdgeInsets.all(w * 0.03),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(w * 0.025),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: w * 0.05),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: w * 0.038,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: w * 0.04,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, double w) {
    return Row(
      children: [
        Icon(icon, color: AppColors.darkPrimary, size: w * 0.045),
        SizedBox(width: w * 0.02),
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: w * 0.036,
            color: AppColors.darkGrey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: w * 0.038,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  bool _hasWarningSignsData(VoluntaryParameters params) {
    return params.fever == true ||
        params.chills == true ||
        params.newAbdominalPain == true ||
        params.suddenUnwell == true;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy \'at\' h:mm a').format(date);
  }
}