import 'package:digitaldailysis/pages/patient/VideoPlayerScreen.dart';
import 'package:digitaldailysis/pages/patient/display_patient.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/login_controller.dart';
import '../../controllers/patient_panel_controller.dart';
import '../../utils/colors.dart';
import '../patient/material_session_details.dart';

class PatientHomeScreen extends StatelessWidget {
  final String patientId;

  const PatientHomeScreen({super.key, required this.patientId});

  String _formatDate(DateTime dt) {
    return DateFormat('dd MMM yyyy • hh:mm a').format(dt);
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'acknowledged':
        return AppStatusColors.success;
      case 'active':
        return AppStatusColors.active;
      case 'pending':
        return AppStatusColors.pending;
      default:
        return AppStatusColors.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientPanelController>(tag: patientId);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.lightGrey,
        appBar: AppBar(
          backgroundColor: AppColors.darkPrimary,
          elevation: 0,
          title: const Text(
            'My Health Portal',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout, color: AppColors.white),
              onPressed: () => Get.find<LoginController>().logout(),
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.white,
            indicatorWeight: 3,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
            labelStyle: TextStyle(
              fontSize: w * 0.035,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.medical_services_outlined),
                text: 'My Dialysis Care',
              ),
              Tab(
                icon: Icon(Icons.school_outlined),
                text: 'My Lectures',
              ),
              Tab(
                icon: Icon(Icons.contact_phone_outlined),
                text: 'Emergency',
              ),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.summary.value == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.errorMsg.value.isNotEmpty
                        ? controller.errorMsg.value
                        : "No data available",
                    textAlign: TextAlign.center,
                  ),
                  TextButton.icon(
                    onPressed: controller.fetchSummary,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final data = controller.summary.value!;
          final patient = data.patient;

          return TabBarView(
            children: [
              // ================= MY DIALYSIS CARE TAB =================
              _buildDialysisCareTab(context, w, h, patient, data, controller),

              // ================= MY LECTURES TAB =================
              _buildLecturesTab(context, w, h, patient),

              // ================= EMERGENCY CONTACTS TAB =================
              _buildEmergencyContactsTab(context, w, h),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDialysisCareTab(
      BuildContext context,
      double w,
      double h,
      dynamic patient,
      dynamic data,
      PatientPanelController controller,
      ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(w * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= GREETING CARD =================
          Container(
            padding: EdgeInsets.all(w * 0.05),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.darkPrimary,
                  AppColors.darkPrimary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(w * 0.04),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkPrimary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(w * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: w * 0.07,
                    backgroundColor: AppColors.lightPrimary,
                    child: Icon(
                      Icons.person,
                      size: w * 0.08,
                      color: AppColors.darkPrimary,
                    ),
                  ),
                ),
                SizedBox(width: w * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${patient.name}',
                        style: TextStyle(
                          fontSize: w * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: h * 0.004),
                      Text(
                        patient.email,
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
          ),

          SizedBox(height: h * 0.035),

          // ================= MY PROFILE CARD =================
          InkWell(
            onTap: () {
              Get.to(() => DisplayPatientPage(
                patientId: patient.id ?? patient._id,
              ));
            },
            borderRadius: BorderRadius.circular(w * 0.04),
            child: Container(
              margin: EdgeInsets.only(bottom: h * 0.03),
              padding: EdgeInsets.all(w * 0.05),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(w * 0.04),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(w * 0.03),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.darkPrimary,
                      size: w * 0.07,
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Medical Profile',
                          style: TextStyle(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: h * 0.004),
                        Text(
                          'View your dialysis and health details',
                          style: TextStyle(
                            fontSize: w * 0.036,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.mediumGrey),
                ],
              ),
            ),
          ),

          // ================= HEADER =================
          Text(
            'My Dialysis Kits',
            style: TextStyle(
              fontSize: w * 0.055,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: h * 0.015),

          // ================= SESSION LIST =================
          ...data.materialSessions.map((session) {
            final createdAt = session.createdAt;
            final statusColor = _statusColor(session.status);

            return Container(
              margin: EdgeInsets.only(bottom: h * 0.018),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(w * 0.04),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(w * 0.04),
                onTap: () async {
                  await controller.fetchMaterialSessionDetails(
                    session.materialSessionId,
                  );

                  final ms = controller.materialSessionDetails.value;

                  if (ms != null) {
                    Get.to(
                          () => MaterialSessionDetailsPage(
                        sessionId: ms.materialSession.materialSessionId,
                        patientId: patientId,
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(w * 0.045),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(w * 0.03),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.medical_services,
                          color: statusColor,
                          size: w * 0.06,
                        ),
                      ),
                      SizedBox(width: w * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dialysis Kit',
                              style: TextStyle(
                                fontSize: w * 0.045,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: h * 0.004),
                            if (createdAt != null)
                              Text(
                                _formatDate(createdAt.toLocal()),
                                style: TextStyle(
                                  fontSize: w * 0.036,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.03,
                          vertical: h * 0.006,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(w * 0.05),
                        ),
                        child: Text(
                          _capitalizeFirst(session.status),
                          style: TextStyle(
                            fontSize: w * 0.034,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: w * 0.02),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.mediumGrey,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLecturesTab(
      BuildContext context,
      double w,
      double h,
      dynamic patient,
      ) {
    // TODO: Replace with actual data from controller
    final lectures = _getDummyLectures();

    return SingleChildScrollView(
      padding: EdgeInsets.all(w * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= WELCOME BANNER =================
          Container(
            padding: EdgeInsets.all(w * 0.05),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.darkPrimary,
                  AppColors.darkPrimary.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(w * 0.04),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkPrimary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.video_library,
                  color: Colors.white,
                  size: w * 0.12,
                ),
                SizedBox(width: w * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Educational Resources',
                        style: TextStyle(
                          fontSize: w * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: h * 0.005),
                      Text(
                        'Learn about your dialysis care',
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
          ),

          SizedBox(height: h * 0.03),

          // ================= CONTENT SECTIONS =================
          _buildContentSection(
            context,
            w,
            h,
            'Videos',
            Icons.play_circle_outline,
            lectures['videos']!,
            AppStatusColors.info,
          ),

          SizedBox(height: h * 0.025),

          _buildContentSection(
            context,
            w,
            h,
            'Documents',
            Icons.picture_as_pdf,
            lectures['pdfs']!,
            AppStatusColors.error,
          ),

          SizedBox(height: h * 0.025),

          _buildContentSection(
            context,
            w,
            h,
            'Images',
            Icons.image,
            lectures['images']!,
            AppStatusColors.success,
          ),
        ],
      ),
    );
  }

  // ================= EMERGENCY CONTACTS TAB =================
  Widget _buildEmergencyContactsTab(
      BuildContext context,
      double w,
      double h,
      ) {
    // TODO: Replace with actual data from controller/backend
    final emergencyContacts = _getEmergencyContacts();

    return SingleChildScrollView(
      padding: EdgeInsets.all(w * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= EMERGENCY BANNER =================
          Container(
            padding: EdgeInsets.all(w * 0.05),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade700,
                  Colors.red.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(w * 0.04),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(w * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emergency,
                    color: Colors.red.shade700,
                    size: w * 0.08,
                  ),
                ),
                SizedBox(width: w * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          fontSize: w * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: h * 0.005),
                      Text(
                        'Quick access to your medical team',
                        style: TextStyle(
                          fontSize: w * 0.038,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: h * 0.03),

          // ================= CONTACT CARDS =================
          ...emergencyContacts.map((contact) {
            return _buildContactCard(context, w, h, contact);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContactCard(
      BuildContext context,
      double w,
      double h,
      Map<String, String> contact,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.018),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(w * 0.045),
        child: Row(
          children: [
            // Doctor Avatar
            Container(
              width: w * 0.15,
              height: w * 0.15,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkPrimary,
                    AppColors.darkPrimary.withValues(alpha: 0.8),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: w * 0.08,
              ),
            ),
            SizedBox(width: w * 0.04),

            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact['name']!,
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: h * 0.004),
                  Text(
                    contact['specialty']!,
                    style: TextStyle(
                      fontSize: w * 0.038,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  SizedBox(height: h * 0.006),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: w * 0.035,
                        color: AppColors.darkPrimary,
                      ),
                      SizedBox(width: w * 0.015),
                      Text(
                        contact['phone']!,
                        style: TextStyle(
                          fontSize: w * 0.038,
                          color: AppColors.darkPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (contact['availability'] != null) ...[
                    SizedBox(height: h * 0.004),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: w * 0.035,
                          color: AppColors.darkGrey,
                        ),
                        SizedBox(width: w * 0.015),
                        Text(
                          contact['availability']!,
                          style: TextStyle(
                            fontSize: w * 0.033,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Call Button
            InkWell(
              onTap: () => _makePhoneCall(contact['phone']!),
              borderRadius: BorderRadius.circular(w * 0.03),
              child: Container(
                padding: EdgeInsets.all(w * 0.035),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(w * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.call,
                  color: Colors.white,
                  size: w * 0.06,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PHONE CALL FUNCTION =================
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          'Error',
          'Unable to make phone call',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initiate call: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ================= DUMMY EMERGENCY CONTACTS =================
  List<Map<String, String>> _getEmergencyContacts() {
    // TODO: Replace with actual data from backend
    return [
      {
        'name': 'Dr. Sarah Johnson',
        'specialty': 'Nephrologist',
        'phone': '+1234567890',
        'availability': 'Available 24/7',
      },
      {
        'name': 'Dr. Michael Chen',
        'specialty': 'Dialysis Specialist',
        'phone': '+1234567891',
        'availability': 'Mon-Fri, 9 AM - 6 PM',
      },
      {
        'name': 'Dr. Emily Rodriguez',
        'specialty': 'Emergency Care Physician',
        'phone': '+1234567892',
        'availability': 'Available 24/7',
      },
      {
        'name': 'Nurse Mary Williams',
        'specialty': 'Dialysis Care Coordinator',
        'phone': '+1234567893',
        'availability': 'Mon-Sat, 8 AM - 8 PM',
      },
      {
        'name': 'Hospital Emergency',
        'specialty': 'Emergency Department',
        'phone': '911',
        'availability': 'Available 24/7',
      },
    ];
  }

  Widget _buildContentSection(
      BuildContext context,
      double w,
      double h,
      String title,
      IconData icon,
      List<Map<String, String>> items,
      Color accentColor,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accentColor, size: w * 0.06),
            SizedBox(width: w * 0.02),
            Text(
              title,
              style: TextStyle(
                fontSize: w * 0.05,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const Spacer(),
            Text(
              '${items.length} items',
              style: TextStyle(
                fontSize: w * 0.036,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
        SizedBox(height: h * 0.015),
        ...items.map((item) => _buildContentCard(
          context,
          w,
          h,
          item,
          icon,
          accentColor,
        )),
      ],
    );
  }

  Widget _buildContentCard(
      BuildContext context,
      double w,
      double h,
      Map<String, String> item,
      IconData icon,
      Color accentColor,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.015),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(w * 0.04),
        onTap: () {
          // TODO: Open video player, PDF viewer, or image viewer
          _openContent(context, item, icon);
        },
        child: Padding(
          padding: EdgeInsets.all(w * 0.04),
          child: Row(
            children: [
              Container(
                width: w * 0.15,
                height: w * 0.15,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(w * 0.03),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: w * 0.08,
                ),
              ),
              SizedBox(width: w * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']!,
                      style: TextStyle(
                        fontSize: w * 0.042,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: h * 0.005),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: w * 0.035,
                          color: AppColors.darkGrey,
                        ),
                        SizedBox(width: w * 0.01),
                        Flexible(
                          child: Text(
                            item['doctor']!,
                            style: TextStyle(
                              fontSize: w * 0.033,
                              color: AppColors.darkGrey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.003),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: w * 0.035,
                          color: AppColors.darkGrey,
                        ),
                        SizedBox(width: w * 0.01),
                        Text(
                          item['date']!,
                          style: TextStyle(
                            fontSize: w * 0.033,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.mediumGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openContent(
      BuildContext context,
      Map<String, String> item,
      IconData icon,
      ) {
    if (icon == Icons.play_circle_outline) {
      // Open video player
      Get.to(() => VideoPlayerScreen(
        title: item['title']!,
        videoUrl: item['url']!,
      ));
    } else if (icon == Icons.picture_as_pdf) {
      // Open PDF in browser
      _launchURL(item['url']!);
    } else if (icon == Icons.image) {
      // Open image viewer
      Get.to(() => ImageViewerScreen(
        title: item['title']!,
        imageUrl: item['url']!,
      ));
    }
  }


  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Unable to open URL',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Opening Content',
        'This will open in your browser',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.darkPrimary,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Map<String, List<Map<String, String>>> _getDummyLectures() {
    return {
      'videos': [
        {
          'title': 'Introduction to Peritoneal Dialysis',
          'doctor': 'Dr. Sarah Johnson',
          'date': '15 Dec 2024',
          'url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          'type': 'youtube',
        },
        {
          'title': 'Managing Your Diet During Dialysis',
          'doctor': 'Dr. Michael Chen',
          'date': '12 Dec 2024',
          'url': 'https://www.youtube.com/watch?v=jNQXAC9IVRw',
          'type': 'youtube',
        },
        {
          'title': 'Home Dialysis Best Practices',
          'doctor': 'Dr. Emily Rodriguez',
          'date': '08 Dec 2024',
          'url': 'https://www.youtube.com/watch?v=9bZkp7q19f0',
          'type': 'youtube',
        },
      ],
      'pdfs': [
        {
          'title': 'Dialysis Patient Care Guidelines',
          'doctor': 'Dr. Robert Smith',
          'date': '18 Dec 2024',
          'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          'type': 'pdf',
        },
        {
          'title': 'Medication Schedule and Instructions',
          'doctor': 'Dr. Sarah Johnson',
          'date': '14 Dec 2024',
          'url': 'https://www.africau.edu/images/default/sample.pdf',
          'type': 'pdf',
        },
      ],
      'images': [
        {
          'title': 'Dialysis Equipment Setup Diagram',
          'doctor': 'Dr. Michael Chen',
          'date': '16 Dec 2024',
          'url': 'https://picsum.photos/800/600?random=1',
          'type': 'image',
        },
        {
          'title': 'Catheter Care Instructions',
          'doctor': 'Dr. Emily Rodriguez',
          'date': '10 Dec 2024',
          'url': 'https://picsum.photos/800/600?random=2',
          'type': 'image',
        },
      ],
    };
  }
}

// ================= IMAGE VIEWER SCREEN =================
class ImageViewerScreen extends StatelessWidget {
  final String title;
  final String imageUrl;

  const ImageViewerScreen({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.darkPrimary,
        title: Text(
          title,
          style: const TextStyle(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator(
                color: AppColors.white,
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              );
            },
          ),
        ),
      ),
    );
  }
}