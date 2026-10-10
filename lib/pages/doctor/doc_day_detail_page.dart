// lib/pages/doctor/day_detail_page.dart

import 'package:digitaldailysis/controllers/doctor_material_controller.dart';
import 'package:digitaldailysis/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/models/patient/patient_info_model.dart';
import 'package:intl/intl.dart';

class DayDetailPage extends StatefulWidget {
  final DayItem day;
  const DayDetailPage({Key? key, required this.day}) : super(key: key);

  @override
  State<DayDetailPage> createState() => _DayDetailPageState();
}

class _DayDetailPageState extends State<DayDetailPage> {
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
    final statusColor = _getStatusColor(widget.day.status);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Beautiful App Bar
          SliverAppBar(
            expandedHeight: h * 0.22,
            floating: false,
            pinned: true,
            backgroundColor: statusColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [statusColor, statusColor.withValues(alpha: 0.7)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: w * 0.18,
                              height: w * 0.18,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(w * 0.04),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${widget.day.dayNumber}',
                                    style: TextStyle(
                                      fontSize: w * 0.08,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'DAY',
                                    style: TextStyle(
                                      fontSize: w * 0.028,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: w * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Treatment Day ${widget.day.dayNumber}',
                                    style: TextStyle(
                                      fontSize: w * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: h * 0.008),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.03,
                                      vertical: h * 0.006,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(w * 0.03),
                                    ),
                                    child: Text(
                                      widget.day.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: w * 0.032,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(w * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Completion Status Card
                  if (widget.day.completedAt != null)
                    _buildCompletionCard(w, h, statusColor),

                  // Treatment Parameters
                  if (widget.day.parameters != null && widget.day.parameters!.isNotEmpty) ...[
                    SizedBox(height: h * 0.02),
                    _buildSectionTitle('Treatment Parameters', Icons.analytics, Colors.blue, w),
                    SizedBox(height: h * 0.015),
                    _buildParametersCard(w, h),
                  ],

                  // Session Images
                  if (widget.day.images.isNotEmpty) ...[
                    SizedBox(height: h * 0.03),
                    _buildSectionTitle('Session Images', Icons.photo_library, Colors.orange, w),
                    SizedBox(height: h * 0.015),
                    _buildImagesGrid(w, h),
                  ],

                  // Verify Section at bottom (only for completed status)
                  if (widget.day.status.toLowerCase() == 'completed') ...[
                    SizedBox(height: h * 0.03),
                    _buildVerifySection(w, h),
                  ],

                  SizedBox(height: h * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard(double w, double h, Color statusColor) {
    return Container(
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withValues(alpha: 0.08), Colors.green.withValues(alpha: 0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.03),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(w * 0.025),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.check_circle, color: Colors.white, size: w * 0.07),
          ),
          SizedBox(width: w * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completed Successfully',
                  style: TextStyle(
                    fontSize: w * 0.04,
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: h * 0.005),
                Text(
                  _formatDateBeautiful(widget.day.completedAt!),
                  style: TextStyle(
                    fontSize: w * 0.036,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
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
                  sessionId: widget.day.sessionId!,
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

  Widget _buildSectionTitle(String title, IconData icon, Color color, double w) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(w * 0.025),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
            ),
            borderRadius: BorderRadius.circular(w * 0.025),
          ),
          child: Icon(icon, color: color, size: w * 0.06),
        ),
        SizedBox(width: w * 0.025),
        Text(
          title,
          style: TextStyle(
            fontSize: w * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildParametersCard(double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildParametersList(widget.day.parameters!, w, h),
      ),
    );
  }

  List<Widget> _buildParametersList(Map<String, dynamic> params, double w, double h) {
    List<Widget> widgets = [];

    params.forEach((key, value) {
      if (value is Map) {
        widgets.add(_buildParameterSection(key, value, w, h));
      } else {
        widgets.add(_buildParameterRow(key, value, w, h));
      }
    });

    return widgets;
  }

  Widget _buildParameterSection(String sectionName, Map<dynamic, dynamic> data, double w, double h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.008),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.withValues(alpha: 0.15), Colors.blue.withValues(alpha: 0.08)],
            ),
            borderRadius: BorderRadius.circular(w * 0.02),
          ),
          child: Text(
            _formatParameterKey(sectionName),
            style: TextStyle(
              fontSize: w * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
        SizedBox(height: h * 0.015),
        ...data.entries.map((e) => Padding(
          padding: EdgeInsets.only(left: w * 0.03),
          child: _buildParameterRow(e.key.toString(), e.value, w, h),
        )).toList(),
        SizedBox(height: h * 0.02),
      ],
    );
  }

  Widget _buildParameterRow(String key, dynamic value, double w, double h) {
    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.012),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: h * 0.006),
            width: w * 0.02,
            height: w * 0.02,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue.shade600],
              ),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: w * 0.025),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: w * 0.038, height: 1.5),
                children: [
                  TextSpan(
                    text: '${_formatParameterKey(key)}: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  TextSpan(
                    text: _formatParameterValue(value),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesGrid(double w, double h) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: w * 0.03,
        mainAxisSpacing: h * 0.015,
        childAspectRatio: 1,
      ),
      itemCount: widget.day.images.length,
      itemBuilder: (_, i) {
        return GestureDetector(
          onTap: () => _showImageDialog(widget.day.images[i].imageUrl, i, w, h),
          child: Hero(
            tag: 'day_image_${widget.day.dayNumber}_$i',
            child: Container(
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
                    Image.network(widget.day.images[i].imageUrl, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
                        ),
                      ),
                    ),
                    Positioned(
                      top: w * 0.02,
                      right: w * 0.02,
                      child: Container(
                        padding: EdgeInsets.all(w * 0.015),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(w * 0.015),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: w * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: w * 0.02,
                      right: w * 0.02,
                      child: Container(
                        padding: EdgeInsets.all(w * 0.015),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(w * 0.015),
                        ),
                        child: Icon(Icons.zoom_in, color: Colors.white, size: w * 0.045),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
                  tag: 'day_image_${widget.day.dayNumber}_$index',
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: h * 0.02,
              left: w * 0.02,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.008),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(w * 0.04),
                ),
                child: Text(
                  'Image ${index + 1} of ${widget.day.images.length}',
                  style: TextStyle(
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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

  String _formatParameterKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatParameterValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is num) return value.toString();
    return value.toString();
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
      default:
        return Colors.grey;
    }
  }
}