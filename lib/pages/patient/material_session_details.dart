// lib/pages/patient/material_session_details.dart
import 'package:digitaldailysis/pages/patient/dialysis_session_details_page.dart';
import 'package:digitaldailysis/routes/route_helper.dart';
import 'package:digitaldailysis/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/patient_panel_controller.dart';

class MaterialSessionDetailsPage extends StatefulWidget {
  final String sessionId;
  final String patientId;

  const MaterialSessionDetailsPage({
    super.key,
    required this.sessionId,
    required this.patientId,
  });

  @override
  State<MaterialSessionDetailsPage> createState() =>
      _MaterialSessionDetailsPageState();
}

class _MaterialSessionDetailsPageState
    extends State<MaterialSessionDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
      Get.find<PatientPanelController>(tag: widget.patientId);
      // print("In patients panel");
      controller.fetchMaterialSessionDetails(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientPanelController>(tag: widget.patientId);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.white,
          onPressed: () {
            // Refresh the home summary, then return to it
            controller.fetchSummary();
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              Get.offNamed(RouteHelper.getPatientHomeScreen(widget.patientId));
            }
          },
        ),
        title: const Text(
          "Material Session Details",
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.darkPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.darkPrimary,
            ),
          );
        }

        final session = controller.materialSessionDetails.value;

        if (session == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: AppStatusColors.error),
                SizedBox(height: 16),
                Text(
                  "Session not found",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    controller.fetchSummary();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    foregroundColor: AppColors.white,
                  ),
                  child: Text("Refresh"),
                ),
              ],
            ),
          );
        }

        final stats = _calculateStats(session.materialSession);
        final canStartNew = _canStartNewSession(session.materialSession);
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusHeader(session.materialSession, screenWidth),
              _buildStatsCard(stats, screenWidth),
              if (canStartNew)
                _buildStartSessionButton(context, session.materialSession, screenWidth, screenHeight),
              _buildMaterialsSection(session.materialSession, screenWidth),
              if (session.materialSession.materialImages != null &&
                  session.materialSession.materialImages.isNotEmpty)
                _buildMaterialImagesSection(
                    session.materialSession.materialImages, screenWidth),
              _buildDialysisSessionsSection(session.materialSession, screenWidth, screenHeight),
              if (session.materialSession.status != "acknowledged")
                _buildAcknowledgeButton(
                    context, controller, widget.sessionId, screenWidth, screenHeight),
              SizedBox(height: screenWidth * 0.04),
            ],
          ),
        );
      }),
    );
  }

  // Add this method to check if new session can be started
  bool _canStartNewSession(dynamic session) {
    final remaining = session.remainingSessions ?? 0;
    final dialysisSessions = session.dialysisSessions ?? [];

    // Check if there are remaining sessions
    if (remaining <= 0) return false;

    // Check if session is acknowledged
    if (session.status != "acknowledged") return false;

    // Check if there's no active session
    // final hasActiveSession = dialysisSessions.any((s) => s.status == "active");
    // if (hasActiveSession) return false;

    return true;
  }

// Add this method to build the Start Session button
  Widget _buildStartSessionButton(
      BuildContext context,
      dynamic session,
      double screenWidth,
      double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to DayVoluntaryScreen
          Get.toNamed(
            RouteHelper.getDayVoluntaryScreen(
              session.materialSessionId,
              (session.completedSessions ?? 0) + 1, // Next session number
              widget.patientId,
            ),
          );
        },
        icon: Icon(Icons.play_circle_filled, size: screenWidth * 0.055),
        label: Text(
          "Start New Dialysis Session",
          style: TextStyle(
            fontSize: screenWidth * 0.042,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStatusColors.success,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.022),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          elevation: 4,
        ),
      ),
    );
  }
  Widget _buildStatusHeader(dynamic session, double screenWidth) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (session.status) {
      case "acknowledged":
        statusColor = AppStatusColors.verified;
        statusIcon = Icons.check_circle;
        statusText = "Materials Acknowledged";
        break;
      case "active":
        statusColor = AppStatusColors.info;
        statusIcon = Icons.pending;
        statusText = "Session Active";
        break;
      default:
        statusColor = AppStatusColors.warning;
        statusIcon = Icons.warning_amber_rounded;
        statusText = "Awaiting Acknowledgment";
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkPrimary,
            AppColors.darkPrimary.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(screenWidth * 0.06),
              border:
              Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: screenWidth * 0.055),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  statusText,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          _buildInfoRow(
            Icons.calendar_today,
            "Created",
            _formatDate(session.createdAt),
            screenWidth,
          ),
          if (session.acknowledgedAt != null) ...[
            SizedBox(height: screenWidth * 0.02),
            _buildInfoRow(
              Icons.check_circle_outline,
              "Acknowledged",
              _formatDate(session.acknowledgedAt),
              screenWidth,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, double screenWidth) {
    return Row(
      children: [
        Icon(icon,
            color: AppColors.white.withValues(alpha: 0.8),
            size: screenWidth * 0.045),
        SizedBox(width: screenWidth * 0.02),
        Text(
          "$label: ",
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.9),
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.white,
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats, double screenWidth) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Card(
        elevation: 3,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.045),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Icon(Icons.bar_chart,
                        color: AppColors.darkPrimary, size: screenWidth * 0.06),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    "Session Statistics",
                    style: TextStyle(
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      "Total Sessions",
                      "${stats['total']}",
                      Icons.medical_services,
                      AppColors.darkPrimary,
                      screenWidth,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: _buildStatItem(
                      "Completed",
                      "${stats['completed']}",
                      Icons.check_circle,
                      AppStatusColors.verified,
                      screenWidth,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      "Verified",
                      "${stats['verified']}",
                      Icons.verified,
                      AppStatusColors.success,
                      screenWidth,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: _buildStatItem(
                      "Remaining",
                      "${stats['remaining']}",
                      Icons.pending_actions,
                      AppStatusColors.pending,
                      screenWidth,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              ClipRRect(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                child: LinearProgressIndicator(
                  value: stats['total'] > 0
                      ? stats['completed'] / stats['total']
                      : 0,
                  backgroundColor: AppColors.lightGrey,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(AppStatusColors.verified),
                  minHeight: screenWidth * 0.025,
                ),
              ),
              SizedBox(height: screenWidth * 0.025),
              Text(
                "Progress: ${stats['total'] > 0 ? ((stats['completed'] / stats['total']) * 100).toStringAsFixed(0) : 0}% Complete",
                style: TextStyle(
                  fontSize: screenWidth * 0.037,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color,
      double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.035),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenWidth * 0.08),
          SizedBox(height: screenWidth * 0.02),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.07,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsSection(dynamic session, double screenWidth) {
    final materials = session.materials;
    final pdMaterials = materials.pdMaterials;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Card(
        elevation: 3,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.045),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Icon(Icons.medical_services,
                        color: AppColors.darkPrimary, size: screenWidth * 0.06),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Text(
                      "PD Materials Provided",
                      style: TextStyle(
                        fontSize: screenWidth * 0.048,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),

              // Sessions Count
              _buildMaterialRow(
                "Total Sessions",
                "${materials.sessionsCount}",
                Icons.event_note,
                AppColors.darkPrimary,
                screenWidth,
              ),
              SizedBox(height: screenWidth * 0.02),

              if (pdMaterials != null) ...[
                // CAPD Materials
                if (pdMaterials.capd != null) ...[
                  _buildSubHeader("CAPD Fluids", screenWidth),
                  SizedBox(height: screenWidth * 0.02),
                  ...pdMaterials.capd!.entries.map((entry) {
                    if (entry.value > 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: screenWidth * 0.02),
                        child: _buildMaterialRow(
                          _formatFluidName(entry.key),
                          "${entry.value}",
                          Icons.water_drop,
                          AppStatusColors.info,
                          screenWidth,
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }).toList(),
                  SizedBox(height: screenWidth * 0.02),
                ],

                // APD Materials
                if (pdMaterials.apd != null) ...[
                  _buildSubHeader("APD Fluids", screenWidth),
                  SizedBox(height: screenWidth * 0.02),
                  ...pdMaterials.apd!.entries.map((entry) {
                    if (entry.value > 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: screenWidth * 0.02),
                        child: _buildMaterialRow(
                          _formatFluidName(entry.key),
                          "${entry.value}",
                          Icons.water_drop,
                          AppStatusColors.active,
                          screenWidth,
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }).toList(),
                  SizedBox(height: screenWidth * 0.02),
                ],

                // Other Supplies
                _buildSubHeader("Other Supplies", screenWidth),
                SizedBox(height: screenWidth * 0.02),
                _buildMaterialRow(
                  "Transfer Set",
                  "${pdMaterials.transferSet}",
                  Icons.settings_input_component,
                  AppStatusColors.verified,
                  screenWidth,
                ),
                SizedBox(height: screenWidth * 0.02),
                _buildMaterialRow(
                  "Icodextrin 2L",
                  "${pdMaterials.icodextrin2L}",
                  Icons.local_drink,
                  AppStatusColors.verified,
                  screenWidth,
                ),
                SizedBox(height: screenWidth * 0.02),
                _buildMaterialRow(
                  "Minicap",
                  "${pdMaterials.minicap}",
                  Icons.medical_services_outlined,
                  AppStatusColors.verified,
                  screenWidth,
                ),

                // Others (custom items)
                if (pdMaterials.others != null) ...[
                  SizedBox(height: screenWidth * 0.02),
                  _buildMaterialRow(
                    pdMaterials.others!['description'] ?? 'Other',
                    "${pdMaterials.others!['quantity'] ?? 0}",
                    Icons.inventory_2,
                    AppStatusColors.warning,
                    screenWidth,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubHeader(String title, double screenWidth) {
    return Row(
      children: [
        Container(
          width: 3,
          height: screenWidth * 0.04,
          decoration: BoxDecoration(
            color: AppColors.darkPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
            color: AppColors.darkPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialRow(String label, String value, IconData icon,
      Color color, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: screenWidth * 0.05),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.025,
              vertical: screenWidth * 0.01,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.white,
                fontSize: screenWidth * 0.036,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFluidName(String key) {
    // Convert "fluid1_5_2L" to "1.5% (2L)"
    final parts = key.replaceAll('fluid', '').split('_');
    if (parts.length >= 3) {
      final concentration = parts[0] + '.' + parts[1];
      final volume = parts[2];
      return "$concentration% ($volume)";
    }
    return key;
  }

  Widget _buildMaterialImagesSection(
      List<dynamic> images, double screenWidth) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Card(
        elevation: 3,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.045),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Icon(Icons.photo_library,
                        color: AppColors.darkPrimary, size: screenWidth * 0.06),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    "Material Images",
                    style: TextStyle(
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: screenWidth * 0.025,
                  mainAxisSpacing: screenWidth * 0.025,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final imageUrl =
                      images[index]?.imageUrl ?? images[index]?['imageUrl'] ?? '';

                  if (imageUrl.isEmpty) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(
                            color: AppColors.mediumGrey.withValues(alpha: 0.3)),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: screenWidth * 0.08,
                        color: AppColors.mediumGrey,
                      ),
                    );
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGrey, width: 2),
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.lightGrey,
                            child: Icon(
                              Icons.broken_image,
                              size: screenWidth * 0.08,
                              color: AppColors.mediumGrey,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialysisSessionsSection(
      dynamic session, double screenWidth, double screenHeight) {
    final dialysisSessions = session.dialysisSessions ?? [];

    if (dialysisSessions.isEmpty) {
      return Container(
        margin: EdgeInsets.all(screenWidth * 0.04),
        child: Card(
          elevation: 3,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.06),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.event_busy,
                      size: screenWidth * 0.15, color: AppColors.mediumGrey),
                  SizedBox(height: screenWidth * 0.03),
                  Text(
                    "No Dialysis Sessions Yet",
                    style: TextStyle(
                      fontSize: screenWidth * 0.042,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    "Sessions will appear here once you start dialysis",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Card(
        elevation: 3,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.045),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Icon(Icons.event_note,
                        color: AppColors.darkPrimary, size: screenWidth * 0.06),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    "Dialysis Sessions",
                    style: TextStyle(
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              ...dialysisSessions.asMap().entries.map((entry) {
                final index = entry.key;
                final dialysisSession = entry.value;
                return _buildDialysisSessionTile(
                    dialysisSession, index + 1, screenWidth, screenHeight);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialysisSessionTile(dynamic dialysisSession, int sessionNumber,
      double screenWidth, double screenHeight) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (dialysisSession.status) {
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

    // ✅ Check if session can be viewed (completed or verified)
    final canView = dialysisSession.status == "completed" ||
        dialysisSession.status == "verified";

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: InkWell(
        onTap: canView
            ? () {
          // ✅ Navigate to details page
          Get.to(
                () => DialysisSessionDetailsPage(
              session: dialysisSession,
              sessionNumber: sessionNumber,
            ),
          );
        }
            : null, // Disable tap for non-viewable sessions
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [statusColor, statusColor.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "$sessionNumber",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Session $sessionNumber",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Row(
                          children: [
                            Icon(statusIcon,
                                size: screenWidth * 0.04, color: statusColor),
                            SizedBox(width: screenWidth * 0.015),
                            Flexible(
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // ✅ Show appropriate icon based on whether it's viewable
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      canView ? Icons.arrow_forward_ios : Icons.pending_actions,
                      color: statusColor,
                      size: screenWidth * 0.045,
                    ),
                  ),
                ],
              ),
              if (dialysisSession.completedAt != null) ...[
                SizedBox(height: screenWidth * 0.03),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.025),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time,
                          size: screenWidth * 0.04, color: AppColors.darkGrey),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        "Completed: ${_formatDate(dialysisSession.completedAt)}",
                        style: TextStyle(
                          fontSize: screenWidth * 0.033,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (dialysisSession.parameters?.voluntary?.comments != null &&
                  dialysisSession.parameters!.voluntary!.comments!.isNotEmpty) ...[
                SizedBox(height: screenWidth * 0.02),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.025),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.comment,
                          size: screenWidth * 0.04, color: AppColors.darkGrey),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Text(
                          dialysisSession.parameters!.voluntary!.comments!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.033,
                            color: AppColors.darkGrey,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // ✅ Add hint text for viewable sessions
              if (canView) ...[
                SizedBox(height: screenWidth * 0.015),
                Text(
                  "Tap to view full details",
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: statusColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcknowledgeButton(BuildContext context,
      PatientPanelController controller, String sessionId,
      double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirm = await Get.dialog<bool>(
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              title: Text(
                "Acknowledge Materials",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              content: Text(
                "Have you received and verified all the materials for this session?",
                style: TextStyle(color: AppColors.darkGrey),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: AppColors.mediumGrey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                  ),
                  child: Text("Confirm"),
                ),
              ],
            ),
          );

          if (confirm == true) {
            final ok = await controller.acknowledgeSession(sessionId);
            if (ok) {
              await controller.fetchMaterialSessionDetails(widget.sessionId);
              Get.snackbar(
                "Success",
                "Materials Acknowledged Successfully",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppStatusColors.verified,
                colorText: AppColors.white,
                icon: Icon(Icons.check_circle, color: AppColors.white),
              );
            }
          }
        },
        icon: Icon(Icons.check_circle, size: screenWidth * 0.055),
        label: Text(
          "Acknowledge Materials",
          style: TextStyle(
            fontSize: screenWidth * 0.042,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.022),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats(dynamic session) {
    final dialysisSessions = session.dialysisSessions ?? [];
    int total = session.totalSessionsAllowed ?? 0;
    int completed = session.completedSessions ?? 0;
    int verified =
        dialysisSessions.where((s) => s.status == "verified").length;
    int remaining = session.remainingSessions ?? 0;

    return {
      'total': total,
      'completed': completed,
      'verified': verified,
      'remaining': remaining,
    };
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';
    try {
      DateTime date;
      if (dateValue is DateTime) {
        date = dateValue;
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else {
        return 'N/A';
      }

      return DateFormat('MMM dd, yyyy \'at\' h:mm a').format(date);
    } catch (e) {
      return dateValue.toString();
    }
  }
}