import 'package:flutter/material.dart';


class DayDetailsPage extends StatelessWidget {
  final String materialSessionId;
  final int dayNumber;
  final String patientId;


  const DayDetailsPage({
    super.key,
    required this.materialSessionId,
    required this.dayNumber,
    required this.patientId,
  });


  @override
  Widget build(BuildContext context) {
    return  Container();
  }
  }
//     final controller = Get.find<PatientPanelController>(tag: patientId);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Day $dayNumber Details"),
//         elevation: 0,
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         }
//
//         final session = controller.materialSessionDetails.value;
//         final day = session!.days.firstWhere((d) => d.dayNumber == dayNumber);
//
//         switch (day.status) {
//           case "pending":
//             return _buildPendingView(context, session, day, screenWidth, screenHeight);
//
//           case "active":
//           // 🔴 Dialysis not yet completed
//             return _buildActiveDialysisView(context, day, screenWidth);
//
//           case "completed":
//           // 🟡 Completed but NOT verified
//             return _buildCompletedUnverifiedView(context, day, screenWidth);
//
//           case "verified":
//           // 🟢 Completed + verified
//             return _buildCompletedVerifiedView(context, day, screenWidth);
//
//           default:
//             return Center(child: Text("Unknown status"));
//         }
//
//       }),
//     );
//   }
//
//   Widget _buildPendingView(BuildContext context, dynamic session, dynamic day, double screenWidth, double screenHeight) {
//     final canStart = _canStartDay(session, dayNumber);
//
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.06),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.pending_actions, size: screenWidth * 0.2, color: Colors.orange),
//             SizedBox(height: screenHeight * 0.03),
//             Text(
//               "Dialysis Session Not Started",
//               style: TextStyle(fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: screenHeight * 0.015),
//             Text(
//               canStart
//                   ? "Ready to start Day $dayNumber dialysis session"
//                   : "Complete previous days first",
//               style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: screenHeight * 0.04),
//             ElevatedButton.icon(
//               onPressed: canStart
//                   ? () {
//                 Get.to(
//                       () => DayVoluntaryScreen(
//                     materialSessionId: materialSessionId,
//                     dayNumber: dayNumber,
//                      patientId: patientId,
//                   ),
//
//                 );
//               }
//                   : null,
//               icon: Icon(Icons.play_arrow),
//               label: Text("Start Dialysis Session"),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: screenWidth * 0.08,
//                   vertical: screenHeight * 0.02,
//                 ),
//                 textStyle: TextStyle(fontSize: screenWidth * 0.04),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActiveDialysisView(
//       BuildContext context,
//       dynamic day,
//       double screenWidth,
//       ) {
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.06),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Icon
//             Icon(
//               Icons.play_circle_fill,
//               size: screenWidth * 0.22,
//               color: Colors.orange,
//             ),
//
//             SizedBox(height: screenHeight * 0.03),
//
//             // Title
//             Text(
//               "Dialysis In Progress",
//               style: TextStyle(
//                 fontSize: screenWidth * 0.055,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//
//             SizedBox(height: screenHeight * 0.015),
//
//             // Subtitle
//             Text(
//               "Please complete today's dialysis session.",
//               style: TextStyle(
//                 fontSize: screenWidth * 0.04,
//                 color: Colors.grey[600],
//               ),
//               textAlign: TextAlign.center,
//             ),
//
//             SizedBox(height: screenHeight * 0.04),
//
//             // CTA Button
//             ElevatedButton.icon(
//               icon: const Icon(Icons.arrow_forward),
//               label: const Text("Continue Dialysis"),
//               onPressed: () {
//                 Get.off(
//                       () => DayVoluntaryScreen(
//                     materialSessionId: materialSessionId,
//                     dayNumber: day.dayNumber,
//                         patientId: patientId,
//                   ),
//
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: screenWidth * 0.1,
//                   vertical: screenHeight * 0.02,
//                 ),
//                 textStyle: TextStyle(
//                   fontSize: screenWidth * 0.042,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCompletedUnverifiedView(BuildContext context, dynamic day, double screenWidth) {
//     final params = day.parameters;
//     final voluntary = params['voluntary'] ?? {};
//     final dialysis = params['dialysis'] ?? {};
//
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           _buildStatusBanner(
//             "Session Completed - Awaiting Doctor Verification",
//             Colors.blue,
//             Icons.pending,
//             screenWidth,
//           ),
//           Padding(
//             padding: EdgeInsets.all(screenWidth * 0.04),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildSectionCard(
//                   "Voluntary Parameters",
//                   [
//                     _buildInfoRow("Feeling OK", voluntary['feelingOk'] ?? 'N/A', screenWidth),
//                     _buildInfoRow("Fever", voluntary['fever'] ?? 'N/A', screenWidth),
//                     if (voluntary['comment']?.isNotEmpty ?? false)
//                       _buildInfoRow("Comment", voluntary['comment'], screenWidth),
//                   ],
//                   Icons.person,
//                   screenWidth,
//                 ),
//                 SizedBox(height: screenWidth * 0.04),
//                 _buildSectionCard(
//                   "Dialysis Parameters",
//                   [
//                     if (dialysis['fillVolume']?.isNotEmpty ?? false)
//                       _buildInfoRow("Fill Volume", dialysis['fillVolume'], screenWidth),
//                     if (dialysis['drainVolume']?.isNotEmpty ?? false)
//                       _buildInfoRow("Drain Volume", dialysis['drainVolume'], screenWidth),
//                     if (dialysis['fillTime']?.isNotEmpty ?? false)
//                       _buildInfoRow("Fill Time", dialysis['fillTime'], screenWidth),
//                     if (dialysis['drainTime']?.isNotEmpty ?? false)
//                       _buildInfoRow("Drain Time", dialysis['drainTime'], screenWidth),
//                     if (dialysis['bloodPressure']?.isNotEmpty ?? false)
//                       _buildInfoRow("Blood Pressure", dialysis['bloodPressure'], screenWidth),
//                     if (dialysis['weightPre']?.isNotEmpty ?? false)
//                       _buildInfoRow("Weight (Pre)", dialysis['weightPre'], screenWidth),
//                     if (dialysis['weightPost']?.isNotEmpty ?? false)
//                       _buildInfoRow("Weight (Post)", dialysis['weightPost'], screenWidth),
//                     _buildInfoRow("Exchanges", "${dialysis['numberOfExchanges'] ?? 0}", screenWidth),
//                     _buildInfoRow("Duration", "${dialysis['durationMinutes'] ?? 0} min", screenWidth),
//                   ],
//                   Icons.water_drop,
//                   screenWidth,
//                 ),
//                 SizedBox(height: screenWidth * 0.04),
//                 if (day.images != null && day.images.isNotEmpty)
//                   _buildImagesSection(day.images, screenWidth),
//                 SizedBox(height: screenWidth * 0.04),
//                 _buildRemarkCard(
//                   "⚠️ Not Yet Verified by Doctor",
//                   "This session is awaiting doctor's verification and approval.",
//                   Colors.orange,
//                   screenWidth,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCompletedVerifiedView(BuildContext context, dynamic day, double screenWidth) {
//     final params = day.parameters;
//     final voluntary = params['voluntary'] ?? {};
//     final dialysis = params['dialysis'] ?? {};
//
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           _buildStatusBanner(
//             "Session Completed & Verified",
//             Colors.green,
//             Icons.check_circle,
//             screenWidth,
//           ),
//           Padding(
//             padding: EdgeInsets.all(screenWidth * 0.04),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildInfoCard("Completed At", _formatDate(day.completedAt), screenWidth),
//                 SizedBox(height: screenWidth * 0.04),
//                 _buildSectionCard(
//                   "Voluntary Parameters",
//                   [
//                     _buildInfoRow("Feeling OK", voluntary['feelingOk'] ?? 'N/A', screenWidth),
//                     _buildInfoRow("Fever", voluntary['fever'] ?? 'N/A', screenWidth),
//                     if (voluntary['comment']?.isNotEmpty ?? false)
//                       _buildInfoRow("Comment", voluntary['comment'], screenWidth),
//                   ],
//                   Icons.person,
//                   screenWidth,
//                 ),
//                 SizedBox(height: screenWidth * 0.04),
//                 _buildSectionCard(
//                   "Dialysis Parameters",
//                   [
//                     if (dialysis['fillVolume']?.isNotEmpty ?? false)
//                       _buildInfoRow("Fill Volume", dialysis['fillVolume'], screenWidth),
//                     if (dialysis['drainVolume']?.isNotEmpty ?? false)
//                       _buildInfoRow("Drain Volume", dialysis['drainVolume'], screenWidth),
//                     if (dialysis['fillTime']?.isNotEmpty ?? false)
//                       _buildInfoRow("Fill Time", dialysis['fillTime'], screenWidth),
//                     if (dialysis['drainTime']?.isNotEmpty ?? false)
//                       _buildInfoRow("Drain Time", dialysis['drainTime'], screenWidth),
//                     if (dialysis['bloodPressure']?.isNotEmpty ?? false)
//                       _buildInfoRow("Blood Pressure", dialysis['bloodPressure'], screenWidth),
//                     if (dialysis['weightPre']?.isNotEmpty ?? false)
//                       _buildInfoRow("Weight (Pre)", dialysis['weightPre'], screenWidth),
//                     if (dialysis['weightPost']?.isNotEmpty ?? false)
//                       _buildInfoRow("Weight (Post)", dialysis['weightPost'], screenWidth),
//                     _buildInfoRow("Exchanges", "${dialysis['numberOfExchanges'] ?? 0}", screenWidth),
//                     _buildInfoRow("Duration", "${dialysis['durationMinutes'] ?? 0} min", screenWidth),
//                   ],
//                   Icons.water_drop,
//                   screenWidth,
//                 ),
//                 SizedBox(height: screenWidth * 0.04),
//                 if (day.images != null && day.images.isNotEmpty)
//                   _buildImagesSection(day.images, screenWidth),
//                 SizedBox(height: screenWidth * 0.04),
//                 _buildRemarkCard(
//                   "✓ Verified by Doctor",
//                   "This session has been reviewed and verified by the doctor.",
//                   Colors.green,
//                   screenWidth,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatusBanner(String text, Color color, IconData icon, double screenWidth) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(screenWidth * 0.04),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         border: Border(bottom: BorderSide(color: color, width: 2)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: screenWidth * 0.07),
//           SizedBox(width: screenWidth * 0.03),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: screenWidth * 0.04,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionCard(String title, List<Widget> children, IconData icon, double screenWidth) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, size: screenWidth * 0.06, color: Colors.blue),
//                 SizedBox(width: screenWidth * 0.02),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenWidth * 0.03),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoCard(String label, String value, double screenWidth) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 label,
//                 style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w500),
//               ),
//             ),
//             SizedBox(width: screenWidth * 0.02),
//             Flexible(
//               child: Text(
//                 value,
//                 style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey[700]),
//                 textAlign: TextAlign.right,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value, double screenWidth) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: TextStyle(fontSize: screenWidth * 0.038, color: Colors.grey[700]),
//             ),
//           ),
//           SizedBox(width: screenWidth * 0.02),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: TextStyle(fontSize: screenWidth * 0.038, fontWeight: FontWeight.w500),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildImagesSection(List<dynamic> images, double screenWidth) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.image, size: screenWidth * 0.06, color: Colors.blue),
//                 SizedBox(width: screenWidth * 0.02),
//                 Text(
//                   "Session Images",
//                   style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenWidth * 0.03),
//             GridView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: screenWidth * 0.02,
//                 mainAxisSpacing: screenWidth * 0.02,
//               ),
//               itemCount: images.length,
//               itemBuilder: (context, index) {
//                 final imageUrl = images[index]?.imageUrl ??
//                     images[index]?['imageUrl'] ?? '';
//
//                 if (imageUrl.isEmpty) {
//                   return Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                     ),
//                     child: Icon(Icons.image_not_supported, size: screenWidth * 0.1),
//                   );
//                 }
//
//                 return ClipRRect(
//                   borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                   child: Image.network(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         color: Colors.grey[300],
//                         child: Icon(Icons.broken_image, size: screenWidth * 0.1),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRemarkCard(String title, String subtitle, Color color, double screenWidth) {
//     return Card(
//       elevation: 2,
//       color: color.withValues(alpha: 0.1),
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         child: Row(
//           children: [
//             Icon(
//               color == Colors.green ? Icons.verified : Icons.pending,
//               color: color,
//               size: screenWidth * 0.08,
//             ),
//             SizedBox(width: screenWidth * 0.03),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.04,
//                       fontWeight: FontWeight.bold,
//                       color: color,
//                     ),
//                   ),
//                   SizedBox(height: screenWidth * 0.01),
//                   Text(
//                     subtitle,
//                     style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[700]),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   bool _canStartDay(dynamic session, int dayNumber) {
//     if (dayNumber == 1) return true;
//
//     try {
//       final previousDay = session.days.firstWhere(
//             (d) => d.dayNumber == dayNumber - 1,
//       );
//       return previousDay.status != "pending";
//     } catch (e) {
//       return false;
//     }
//   }
//
//   String _formatDate(dynamic dateValue) {
//     if (dateValue == null) return 'N/A';
//     try {
//       DateTime date;
//       if (dateValue is DateTime) {
//         date = dateValue;
//       } else if (dateValue is String) {
//         date = DateTime.parse(dateValue);
//       } else {
//         return 'N/A';
//       }
//       return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
//     } catch (e) {
//       return dateValue.toString();
//     }
//   }
// }