import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:digitaldailysis/controllers/create_material_controller.dart';
import 'package:digitaldailysis/utils/colors.dart';

class CreateActiveMaterialScreen extends StatefulWidget {
  final String doctorId;
  final String patientId;

  const CreateActiveMaterialScreen({
    Key? key,
    required this.doctorId,
    required this.patientId,
  }) : super(key: key);

  @override
  State<CreateActiveMaterialScreen> createState() =>
      _CreateActiveMaterialScreenState();
}

class _CreateActiveMaterialScreenState
    extends State<CreateActiveMaterialScreen> {
  late CreateMaterialController controller;
  final ImagePicker _picker = ImagePicker();

  List<XFile> images = [];

  // Basic info
  int sessionsCount = 10;

  // PD Materials
  int transferSet = 2;

  // CAPD Fluids
  int capdFluid1_5_2L = 0;
  int capdFluid2_5_2L = 0;
  int capdFluid4_25_2L = 0;
  int capdFluid1_5_1L = 0;
  int capdFluid2_5_1L = 0;
  int capdFluid4_25_1L = 0;

  // APD Fluids
  int apdFluid1_7_1L = 0;

  // Other materials
  int icodextrin2L = 0;
  int minicap = 0;

  // Others
  final TextEditingController othersDescriptionController =
  TextEditingController();
  int othersQuantity = 0;

  final TextEditingController notesController =
  TextEditingController(text: 'PD supply for 10 sessions');

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      CreateMaterialController(
        doctorId: widget.doctorId,
        patientId: widget.patientId,
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<CreateMaterialController>();
    notesController.dispose();
    othersDescriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked != null) {
      setState(() => images = picked);
    }
  }

  Future<void> submit() async {
    final capdFluids = {
      'fluid1_5_2L': capdFluid1_5_2L,
      'fluid2_5_2L': capdFluid2_5_2L,
      'fluid4_25_2L': capdFluid4_25_2L,
      'fluid1_5_1L': capdFluid1_5_1L,
      'fluid2_5_1L': capdFluid2_5_1L,
      'fluid4_25_1L': capdFluid4_25_1L,
    };

    final apdFluids = {
      'fluid1_7_1L': apdFluid1_7_1L,
    };

    final others = (othersQuantity > 0)
        ? {
      'description': othersDescriptionController.text.trim(),
      'quantity': othersQuantity,
    }
        : null;

    final id = await controller.createAndUpload(
      sessionsCount: sessionsCount,
      transferSet: transferSet,
      capdFluids: capdFluids,
      apdFluids: apdFluids,
      icodextrin2L: icodextrin2L,
      minicap: minicap,
      others: others,
      notes: notesController.text.trim(),
      imageFiles: images,
    );

    if (id != null) {
      Get.back(result: true);
      Get.snackbar(
        'Success',
        'PD material session created successfully',
        backgroundColor: AppColors.darkPrimary,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        controller.errorMsg.value.isEmpty
            ? 'Failed to create material'
            : controller.errorMsg.value,
        backgroundColor: AppColors.black,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.darkPrimary,
        centerTitle: true,
        title: Text(
          'Create PD Material Session',
          style: TextStyle(
            fontSize: w * 0.05,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info Card
            _card(
              w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Basic Information', Icons.info_outline, w),
                  SizedBox(height: h * 0.015),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: sessionsCount.toString(),
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                              'Sessions Count', Icons.event, w),
                          onChanged: (v) {
                            sessionsCount = int.tryParse(v) ?? sessionsCount;
                            notesController.text =
                            'PD supply for $sessionsCount sessions';
                          },
                        ),
                      ),
                      SizedBox(width: w * 0.04),
                      Expanded(
                        child: TextFormField(
                          initialValue: transferSet.toString(),
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                              'Transfer Set', Icons.swap_horiz, w),
                          onChanged: (v) {
                            setState(() {
                              transferSet = int.tryParse(v) ?? transferSet;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.03),

            // CAPD Fluids Card
            _card(
              w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('CAPD Fluids', Icons.water_drop, w),
                  SizedBox(height: h * 0.015),
                  _numberInput('Fluid 1.5% 2L', capdFluid1_5_2L, w,
                          (v) => capdFluid1_5_2L = v),
                  SizedBox(height: h * 0.015),
                  _numberInput('Fluid 2.5% 2L', capdFluid2_5_2L, w,
                          (v) => capdFluid2_5_2L = v),
                  SizedBox(height: h * 0.015),
                  _numberInput('Fluid 4.25% 2L', capdFluid4_25_2L, w,
                          (v) => capdFluid4_25_2L = v),
                  SizedBox(height: h * 0.015),
                  _numberInput('Fluid 1.5% 1L', capdFluid1_5_1L, w,
                          (v) => capdFluid1_5_1L = v),
                  SizedBox(height: h * 0.015),
                  _numberInput('Fluid 2.5% 1L', capdFluid2_5_1L, w,
                          (v) => capdFluid2_5_1L = v),
                  SizedBox(height: h * 0.015),
                  _numberInput('Fluid 4.25% 1L', capdFluid4_25_1L, w,
                          (v) => capdFluid4_25_1L = v),
                ],
              ),
            ),

            SizedBox(height: h * 0.03),

            // APD Fluids Card
            _card(
              w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('APD Fluids', Icons.local_hospital, w),
                  SizedBox(height: h * 0.015),
                  _numberInput('Fluid 1.7% 1L', apdFluid1_7_1L, w,
                          (v) => apdFluid1_7_1L = v),
                ],
              ),
            ),

            SizedBox(height: h * 0.03),

            // Other Materials Card
            _card(
              w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Other Materials', Icons.medical_services, w),
                  SizedBox(height: h * 0.015),
                  _numberInput(
                      'Icodextrin 2L', icodextrin2L, w, (v) => icodextrin2L = v),
                  SizedBox(height: h * 0.015),
                  _numberInput('Minicap', minicap, w, (v) => minicap = v),
                ],
              ),
            ),

            SizedBox(height: h * 0.03),

            // Additional Items Card
            _card(
              w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Additional Items', Icons.inventory_2, w),
                  SizedBox(height: h * 0.015),
                  TextFormField(
                    controller: othersDescriptionController,
                    decoration: _inputDecoration(
                        'Description', Icons.description, w),
                  ),
                  SizedBox(height: h * 0.015),
                  TextFormField(
                    initialValue: othersQuantity.toString(),
                    keyboardType: TextInputType.number,
                    decoration:
                    _inputDecoration('Quantity', Icons.numbers, w),
                    onChanged: (v) {
                      setState(() {
                        othersQuantity = int.tryParse(v) ?? othersQuantity;
                      });
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.03),

            // Notes Card
            _card(
              w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Notes', Icons.note, w),
                  SizedBox(height: h * 0.015),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration:
                    _inputDecoration('Optional notes', Icons.edit_note, w),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.03),

            // Material Images Card
            _card(
              w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Material Images', Icons.photo_library, w),
                  SizedBox(height: h * 0.015),
                  ElevatedButton.icon(
                    onPressed: pickImages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPrimary,
                    ),
                    icon: Icon(Icons.photo, color: AppColors.white),
                    label: Text(
                      'Pick Images',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  if (images.isNotEmpty)
                    SizedBox(
                      height: h * 0.18,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) => SizedBox(width: w * 0.03),
                        itemBuilder: (_, i) {
                          final img = images[i];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(w * 0.03),
                                child: kIsWeb
                                    ? Image.network(
                                  img.path,
                                  width: w * 0.45,
                                  fit: BoxFit.cover,
                                )
                                    : Image.file(
                                  File(img.path),
                                  width: w * 0.45,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: w * 0.015,
                                right: w * 0.015,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => images.removeAt(i)),
                                  child: CircleAvatar(
                                    radius: w * 0.035,
                                    backgroundColor: AppColors.white,
                                    child: Icon(
                                      Icons.close,
                                      size: w * 0.04,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: h * 0.05),

            // Submit Button
            Obx(
                  () => controller.isSubmitting.value
                  ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.darkPrimary,
                ),
              )
                  : SizedBox(
                width: double.infinity,
                height: h * 0.065,
                child: ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.03),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- UI HELPERS ----------

  Widget _card(double w, {required Widget child}) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumGrey.withValues(alpha: 0.3),
            blurRadius: w * 0.02,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title, IconData icon, double w) {
    return Row(
      children: [
        Icon(icon, color: AppColors.darkPrimary, size: w * 0.06),
        SizedBox(width: w * 0.025),
        Text(
          title,
          style: TextStyle(
            fontSize: w * 0.045,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _numberInput(
      String label, int value, double w, ValueChanged<int> onChanged) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(label, Icons.format_list_numbered, w),
      onChanged: (v) {
        setState(() {
          onChanged(int.tryParse(v) ?? value);
        });
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, double w) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.darkPrimary),
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