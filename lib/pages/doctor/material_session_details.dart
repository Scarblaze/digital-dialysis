// lib/pages/doctor/material_session_details.dart

import 'dart:io';

import 'package:digitaldailysis/controllers/patient_info_controller.dart';
import 'package:digitaldailysis/pages/doctor/dailysis_session_detail_page.dart';

import 'package:digitaldailysis/utils/colors.dart';
//import 'package:digitaldailysis/utils/pdf_generator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/pdf_generator.dart';

class MaterialSessionDetailScreen extends StatefulWidget {
  final patientId;
  final materialSessionId;
  final String? patientName; // Add patient name parameter
  const MaterialSessionDetailScreen({
    super.key,
    required this.patientId,
    this.materialSessionId,
    this.patientName,
  });

  @override
  State<MaterialSessionDetailScreen> createState() => _MaterialSessionDetailScreenState();
}

class _MaterialSessionDetailScreenState extends State<MaterialSessionDetailScreen> {

  final controller = Get.find<PatientInfoController>();

  @override
  void initState() {
    super.initState();

    // 🔥 Always reload fresh data when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _requestStoragePermission();
    });
  }


  Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        // Permission granted
      } else {
        // Permission denied
        Get.snackbar(
          'Permission Required',
          'Storage permission is needed to save PDF files',
        );
      }
    }
  }

  // Method to load/reload data
  void _loadData() {
    controller.fetchMaterialSessionDetailsByDoc(
        patientId: widget.patientId,
        materialSessionId: widget.materialSessionId
    );
  }

  @override
  Widget build(BuildContext context) {

    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    return Obx(() {
      final response = controller.materialSessionDetails.value;
      final materialSession = response?.materialSession;
      final materialSessionId = response?.materialSession.materialSessionId;

      if (materialSession == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.lightGrey,
        body: _buildBody(context, materialSession, w, h),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _downloadReport(context, materialSession, w),
          icon: Icon(Icons.picture_as_pdf),
          label: Text('Download Report'),
          backgroundColor: Colors.blue,
        ),
      );
    });
  }

  Widget _buildBody(
      BuildContext context,
      var materialSession,

      double w,
      double h,
      ) {
    final statusColor = _getStatusColor(materialSession.status);
    final statusIcon = _getStatusIcon(materialSession.status);

    return CustomScrollView(
      slivers: [
        // ================= HEADER =================
        SliverAppBar(
          pinned: true,
          expandedHeight: h * 0.24,
          backgroundColor: statusColor,
          actions: [
            // Download Report Button
            IconButton(
              icon: Icon(Icons.picture_as_pdf, color: Colors.white),
              onPressed: () => _downloadReport(context, materialSession, w),
              tooltip: 'Download Report',
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: EdgeInsets.all(w * 0.05),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.all(w * 0.035),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary,
                      borderRadius: BorderRadius.circular(w * 0.035),
                    ),
                    child: Icon(
                      statusIcon,
                      color: Colors.white,
                      size: w * 0.085,
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PD Material Session',
                          style: TextStyle(
                            fontSize: w * 0.04,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: h * 0.008),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: w * 0.03,
                            vertical: h * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(w * 0.04),
                          ),
                          child: Text(
                            materialSession.status.toUpperCase(),
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
                // ---------- META CARDS ----------
                Row(
                  children: [
                    Expanded(
                      child: _buildDateCard(
                        'Created',
                        materialSession.createdAt,
                        Icons.event_available,
                        Colors.blue,
                        w,
                        h,
                      ),
                    ),
                    SizedBox(width: w * 0.03),
                    Expanded(
                      child: _buildInfoCard(
                        'Sessions',
                        '${materialSession.totalSessionsAllowed ?? 0}',
                        Icons.repeat,
                        Colors.purple,
                        w,
                        h,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: h * 0.03),

                // ---------- PROGRESS ----------
                _buildProgressCard(w, h, materialSession),

                SizedBox(height: h * 0.035),

                // ---------- PD MATERIALS ----------
                _buildSectionTitle(
                  'PD Materials Supply',
                  Icons.medical_services,
                  Colors.green,
                  w,
                ),
                SizedBox(height: h * 0.015),
                _buildPDMaterialsCard(w, h, materialSession),

                SizedBox(height: h * 0.035),

                // ---------- IMAGES ----------
                if (materialSession.materialImages != null &&
                    materialSession.materialImages.isNotEmpty) ...[
                  _buildSectionTitle(
                    'Session Images',
                    Icons.photo_library,
                    Colors.orange,
                    w,
                  ),
                  SizedBox(height: h * 0.015),
                  _buildImagesSection(w, h, materialSession),
                  SizedBox(height: h * 0.035),
                ],

                //---------- DIALYSIS SESSIONS ----------
                if (materialSession.dialysisSessions != null &&
                    materialSession.dialysisSessions.isNotEmpty) ...[
                  _buildSectionTitle(
                    'Dialysis Sessions',
                    Icons.calendar_month,
                    Colors.indigo,
                    w,
                  ),
                  SizedBox(height: h * 0.015),

                  ...materialSession.dialysisSessions.asMap().entries.map(
                        (entry) => _buildDialysisSessionCard(

                        entry.value,
                        entry.key + 1,
                        w,
                        h,
                        materialSession.materialSessionId
                    ),
                  ),
                ],

                SizedBox(height: h * 0.03),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard(
      String label,
      DateTime? date,
      IconData icon,
      Color color,
      double w,
      double h,
      ) {
    final formatted = date != null ? _formatDateBeautiful(date) : 'Not Available';

    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(w * 0.02),
            ),
            child: Icon(icon, color: color, size: w * 0.06),
          ),
          SizedBox(height: h * 0.015),
          Text(
            label,
            style: TextStyle(
              fontSize: w * 0.032,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: h * 0.005),
          Text(
            formatted,
            style: TextStyle(
              fontSize: w * 0.036,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              height: 1.3,
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

  Widget _buildInfoCard(
      String label, String value, IconData icon, Color color, double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(w * 0.02),
            ),
            child: Icon(icon, color: color, size: w * 0.06),
          ),
          SizedBox(height: h * 0.015),
          Text(
            label,
            style: TextStyle(
              fontSize: w * 0.032,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: h * 0.005),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: w * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double w, double h, var response) {
    final total = response.totalSessionsAllowed ?? 0;
    final completed = response.completedSessions ?? 0;
    final remaining = response.remainingSessions ?? 0;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: EdgeInsets.all(w * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.05),
            Colors.purple.withValues(alpha: 0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Session Progress',
                style: TextStyle(
                  fontSize: w * 0.042,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: w * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.015),
          ClipRRect(
            borderRadius: BorderRadius.circular(w * 0.02),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: h * 0.012,
            ),
          ),
          SizedBox(height: h * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressStat('Total', total, Colors.blue, w),
              _buildProgressStat('Completed', completed, Colors.green, w),
              _buildProgressStat('Remaining', remaining, Colors.orange, w),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, int value, Color color, double w) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: w * 0.055,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: w * 0.032,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPDMaterialsCard(double w, double h, var materialSession) {
    final materials = materialSession.materials;
    if (materials == null) {
      return Container(
        padding: EdgeInsets.all(w * 0.045),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(w * 0.04),
        ),
        child: Text('No materials data available'),
      );
    }

    final pdMaterials = materials.pdMaterials;
    if (pdMaterials == null) {
      return Container(
        padding: EdgeInsets.all(w * 0.045),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(w * 0.04),
        ),
        child: Text('No PD materials data available'),
      );
    }

    return Container(
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transfer Set
          if (pdMaterials.transferSet != null && pdMaterials.transferSet > 0)
            _buildMaterialItem(
              'Transfer Set',
              '${pdMaterials.transferSet} units',
              Icons.swap_horiz,
              w,
              h,
            ),

          if (pdMaterials.transferSet != null && pdMaterials.transferSet > 0)
            SizedBox(height: h * 0.02),

          // CAPD Section
          if (_hasCapdFluids(pdMaterials.capd)) ...[
            _buildSubsectionHeader('CAPD Fluids', Icons.water_drop, w),
            SizedBox(height: h * 0.01),
            ..._buildCapdFluidsList(pdMaterials.capd, w, h),
            SizedBox(height: h * 0.02),
          ],

          // APD Section
          if (_hasApdFluids(pdMaterials.apd)) ...[
            _buildSubsectionHeader('APD Fluids', Icons.local_hospital, w),
            SizedBox(height: h * 0.01),
            ..._buildApdFluidsList(pdMaterials.apd, w, h),
            SizedBox(height: h * 0.02),
          ],

          // Icodextrin
          if (pdMaterials.icodextrin2L != null && pdMaterials.icodextrin2L > 0)
            _buildMaterialItem(
              'Icodextrin 2L',
              '${pdMaterials.icodextrin2L} units',
              Icons.medical_information,
              w,
              h,
            ),

          if (pdMaterials.icodextrin2L != null && pdMaterials.icodextrin2L > 0)
            SizedBox(height: h * 0.015),

          // Minicap
          if (pdMaterials.minicap != null && pdMaterials.minicap > 0)
            _buildMaterialItem(
              'Minicap',
              '${pdMaterials.minicap} units',
              Icons.medical_services_outlined,
              w,
              h,
            ),

          if (pdMaterials.minicap != null && pdMaterials.minicap > 0)
            SizedBox(height: h * 0.015),

          // Others
          if (pdMaterials.others != null &&
              pdMaterials.others['quantity'] != null &&
              pdMaterials.others['quantity'] > 0) ...[
            _buildMaterialItemWithDescription(
              'Other Materials',
              '${pdMaterials.others['quantity']} units',
              pdMaterials.others['description'] ?? '',
              Icons.inventory_2,
              w,
              h,
            ),
          ],
        ],
      ),
    );
  }

  bool _hasCapdFluids(dynamic capd) {
    if (capd == null) return false;
    final fluids = capd as Map<String, dynamic>;
    return fluids.values.any((value) => value != null && value > 0);
  }

  bool _hasApdFluids(dynamic apd) {
    if (apd == null) return false;
    final fluids = apd as Map<String, dynamic>;
    return fluids.values.any((value) => value != null && value > 0);
  }

  List<Widget> _buildCapdFluidsList(dynamic capd, double w, double h) {
    final fluids = capd as Map<String, dynamic>;
    final fluidsList = <Widget>[];

    final fluidLabels = {
      'fluid1_5_2L': 'Fluid 1.5% 2L',
      'fluid2_5_2L': 'Fluid 2.5% 2L',
      'fluid4_25_2L': 'Fluid 4.25% 2L',
      'fluid1_5_1L': 'Fluid 1.5% 1L',
      'fluid2_5_1L': 'Fluid 2.5% 1L',
      'fluid4_25_1L': 'Fluid 4.25% 1L',
    };

    fluids.forEach((key, value) {
      if (value != null && value > 0) {
        fluidsList.add(
          Padding(
            padding: EdgeInsets.only(bottom: h * 0.01),
            child: _buildSubMaterialItem(
              fluidLabels[key] ?? key,
              '$value bags',
              w,
              h,
            ),
          ),
        );
      }
    });

    return fluidsList;
  }

  List<Widget> _buildApdFluidsList(dynamic apd, double w, double h) {
    final fluids = apd as Map<String, dynamic>;
    final fluidsList = <Widget>[];

    final fluidLabels = {
      'fluid1_7_1L': 'Fluid 1.7% 1L',
    };

    fluids.forEach((key, value) {
      if (value != null && value > 0) {
        fluidsList.add(
          Padding(
            padding: EdgeInsets.only(bottom: h * 0.01),
            child: _buildSubMaterialItem(
              fluidLabels[key] ?? key,
              '$value bags',
              w,
              h,
            ),
          ),
        );
      }
    });

    return fluidsList;
  }

  Widget _buildSubsectionHeader(String title, IconData icon, double w) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(w * 0.02),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(w * 0.02),
          ),
          child: Icon(icon, color: Colors.green[700], size: w * 0.045),
        ),
        SizedBox(width: w * 0.02),
        Text(
          title,
          style: TextStyle(
            fontSize: w * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildSubMaterialItem(String label, String value, double w, double h) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.035, vertical: h * 0.012),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(w * 0.025),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: w * 0.015,
            height: w * 0.015,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: w * 0.025),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: w * 0.036,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: w * 0.035,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialItem(
      String label,
      String value,
      IconData icon,
      double w,
      double h,
      ) {
    return Container(
      padding: EdgeInsets.all(w * 0.035),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withValues(alpha: 0.05), Colors.green.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(w * 0.03),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(w * 0.02),
            ),
            child: Icon(
              icon,
              color: Colors.green[700],
              size: w * 0.055,
            ),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: w * 0.038,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: h * 0.003),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: w * 0.032,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green[600], size: w * 0.055),
        ],
      ),
    );
  }

  Widget _buildMaterialItemWithDescription(
      String label,
      String value,
      String description,
      IconData icon,
      double w,
      double h,
      ) {
    return Container(
      padding: EdgeInsets.all(w * 0.035),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withValues(alpha: 0.05), Colors.green.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(w * 0.03),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(w * 0.02),
            ),
            child: Icon(
              icon,
              color: Colors.green[700],
              size: w * 0.055,
            ),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: w * 0.038,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: h * 0.003),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: w * 0.032,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: h * 0.005),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: w * 0.03,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green[600], size: w * 0.055),
        ],
      ),
    );
  }

  Widget _buildImagesSection(double w, double h, var response) {
    return Container(
      height: h * 0.22,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: response.materialImages.length,
        separatorBuilder: (_, __) => SizedBox(width: w * 0.03),
        itemBuilder: (_, i) {
          final img = response.materialImages[i];
          return GestureDetector(
            onTap: () => _showImageDialog(img.imageUrl ?? '', i, w, h),
            child: Hero(
              tag: 'session_image_$i',
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
                      Image.network(img.imageUrl ?? '', fit: BoxFit.cover),
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

  Widget _buildDialysisSessionCard(
      dynamic session,
      int sessionNumber,
      double w,
      double h,
      String materialSessionId,
      ) {
    final status = session.status ?? 'unknown';
    final completedAt = session.completedAt;
    final sessionStatusColor = _getStatusColor(status);
    final sessionStatusIcon = _getStatusIcon(status);

    return Container(
      margin: EdgeInsets.only(bottom: h * 0.015),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, sessionStatusColor.withValues(alpha: 0.03)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: sessionStatusColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: sessionStatusColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            // Navigate to dialysis session detail page and wait for result
            final result = await Get.to(
                  () => DialysisSessionDetailPage(
                session: session,
                sessionNumber: sessionNumber,
                materialSessionId: materialSessionId,
              ),
            );

            // 🔥 Always reload data when coming back from detail page
            // This ensures the status is updated if session was verified
            _loadData();
          },
          borderRadius: BorderRadius.circular(w * 0.04),
          child: Padding(
            padding: EdgeInsets.all(w * 0.04),
            child: Row(
              children: [
                Container(
                  width: w * 0.16,
                  height: w * 0.16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        sessionStatusColor,
                        sessionStatusColor.withValues(alpha: 0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(w * 0.03),
                    boxShadow: [
                      BoxShadow(
                        color: sessionStatusColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$sessionNumber',
                        style: TextStyle(
                          fontSize: w * 0.065,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'SESSION',
                        style: TextStyle(
                          fontSize: w * 0.022,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.5,
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
                        'Dialysis Session $sessionNumber',
                        style: TextStyle(
                          fontSize: w * 0.042,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: h * 0.008),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: w * 0.025, vertical: h * 0.005),
                        decoration: BoxDecoration(
                          color: sessionStatusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(w * 0.02),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(sessionStatusIcon,
                                size: w * 0.035, color: sessionStatusColor),
                            SizedBox(width: w * 0.015),
                            Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: w * 0.03,
                                color: sessionStatusColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (completedAt != null) ...[
                        SizedBox(height: h * 0.008),
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: w * 0.032, color: Colors.grey[600]),
                            SizedBox(width: w * 0.015),
                            Text(
                              'Completed: ${_formatDateBeautiful(completedAt)}',
                              style: TextStyle(
                                fontSize: w * 0.032,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: sessionStatusColor, size: w * 0.045),
              ],
            ),
          ),
        ),
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
                  tag: 'session_image_$index',
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

  // Download Report Method
  Future<void> _downloadReport(
      BuildContext context,
      dynamic materialSession,
      double w,
      ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(w * 0.05),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(w * 0.04),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: w * 0.04),
              Text('Generating PDF Report...'),
            ],
          ),
        ),
      ),
    );

    try {
      // Get patient name
      final patientName = widget.patientName ?? 'Patient';

      // Generate PDF
      await MaterialSessionPdfGenerator.generateMaterialSessionReport(
        materialSession: materialSession,
        patientName: patientName,
      );

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      Get.snackbar(
        'Success',
        'PDF Report downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: EdgeInsets.all(w * 0.04),
        borderRadius: w * 0.03,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to generate PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(w * 0.04),
        borderRadius: w * 0.03,
        duration: Duration(seconds: 3),
      );
    }
  }
}