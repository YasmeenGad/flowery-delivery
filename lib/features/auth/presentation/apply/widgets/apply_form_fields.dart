import 'dart:io';

import 'package:flowery_delivery/core/styles/colors/my_colors.dart';
import 'package:flowery_delivery/core/utils/extension/navigation.dart';
import 'package:flowery_delivery/core/utils/widgets/app_text_form_field.dart';
import 'package:flowery_delivery/core/utils/widgets/base/app_loader.dart';
import 'package:flowery_delivery/core/utils/widgets/spacing.dart';
import 'package:flowery_delivery/features/auth/presentation/apply/widgets/upload_license_card_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/validators.dart';
import '../viewModel/apply_form_view_model.dart';

class ApplyFormFields extends StatefulWidget {
  final TextEditingController countryController;
  final TextEditingController firstLegalNameController;
  final TextEditingController secondLegalNameController;
  final TextEditingController vehicleTypeController;
  final TextEditingController vehicleNumberController;
  final TextEditingController vehicleLicenseController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  final TextEditingController idNumberController;
  final TextEditingController idImageController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const ApplyFormFields({
    super.key,
    required this.countryController,
    required this.firstLegalNameController,
    required this.secondLegalNameController,
    required this.vehicleTypeController,
    required this.vehicleNumberController,
    required this.vehicleLicenseController,
    required this.emailController,
    required this.phoneNumberController,
    required this.idNumberController,
    required this.idImageController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<ApplyFormFields> createState() => _ApplyFormFieldsState();
}

class _ApplyFormFieldsState extends State<ApplyFormFields> {
  late ApplyFormViewModel _applyFormViewModel;

  @override
  void initState() {
    super.initState();
    _applyFormViewModel = ApplyFormViewModel();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    await _applyFormViewModel.loadCountries();
    setState(() {});
  }

  Future<void> _pickImageForLicense() async {
    final pickedFile = await _applyFormViewModel.pickImage();
    if (pickedFile?.path.split(".").last == "png" ||
        pickedFile?.path.split(".").last == "jpeg") {
      if (pickedFile != null) {
        setState(() {
          widget.vehicleLicenseController.text = pickedFile.path;
        });
      }
    }
  }

  Future<void> _pickImageForId() async {
    final pickedFile = await _applyFormViewModel.pickImage();
    if (pickedFile?.path.split(".").last == "png" ||
        pickedFile?.path.split(".").last == "jpeg") {
      if (pickedFile != null) {
        setState(() {
          widget.idImageController.text = pickedFile.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          validator: (value) {
            return Validators.validateNotEmpty(
                title: 'Country', value: value, context: context);
          },
          decoration: InputDecoration(
            labelText: 'Country',
            border: OutlineInputBorder(),
          ),
          value: _applyFormViewModel.selectedCountry,
          items: _applyFormViewModel.countries.map((country) {
            return DropdownMenuItem<String>(
              value: country['name'],
              child: Text('${country['flag']} ${country['name']}',
                  style: TextStyle(
                      fontSize: 12.sp, overflow: TextOverflow.ellipsis)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _applyFormViewModel.selectedCountry = value;
              widget.countryController.text = value!;
            });
          },
        ),
        verticalSpacing(20.h),
        AppTextFormField(
          validator: (value) {
            return Validators.validateNotEmpty(
                title: 'First Legal Name', value: value, context: context);
          },
          controller: widget.firstLegalNameController,
          hintText: 'Enter first legal name',
          labelText: 'First Legal Name',
        ),
        verticalSpacing(20.h),
        AppTextFormField(
          validator: (value) {
            return Validators.validateNotEmpty(
                title: 'Second Legal Name', value: value, context: context);
          },
          controller: widget.secondLegalNameController,
          hintText: 'Enter second legal name',
          labelText: 'Second Legal Name',
        ),
        verticalSpacing(20.h),
        AppTextFormField(
          validator: (value) {
            return Validators.validateVehicleType(value, context);
          },
          controller: widget.vehicleTypeController,
          hintText: 'Enter vehicle type',
          labelText: 'Vehicle Type',
        ),
        verticalSpacing(20.h),
        AppTextFormField(
          validator: (value) {
            return Validators.validateNotEmpty(
                title: 'Vehicle Number', value: value, context: context);
          },
          controller: widget.vehicleNumberController,
          hintText: 'Enter vehicle number',
          labelText: 'Vehicle Number',
        ),
        verticalSpacing(20.h),
        AppTextFormField(
          controller: widget.vehicleLicenseController,
          hintText: 'Upload license photo',
          labelText: 'Vehicle License',
          suffixIcon: GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return UploadLicenseCardDialog(
                      onSaved: (imagePath) async {
                        _applyFormViewModel.pickLicenseCard(imagePath);
                        if (_applyFormViewModel
                            .licenseCardPath.value.isNotEmpty) {
                          await _applyFormViewModel
                              .getLicenseCardDataFromImagePath(
                                  _applyFormViewModel.licenseCardPath.value);
                          widget.vehicleLicenseController.text =
                              _applyFormViewModel.licenseCardData[1];
                          widget.firstLegalNameController.text =
                              _applyFormViewModel.licenseCardData[2]
                                  .split(' ')[0];
                          widget.secondLegalNameController.text =
                              _applyFormViewModel.licenseCardData[2]
                                  .split(' ')[1];
                          if (_applyFormViewModel.licenseCardData.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => AppLoader(),
                            );
                          } else {
                            debugPrint(
                                'Saved image path 2: ${_applyFormViewModel.licenseCardPath.value}');
                            context.pop();
                          }
                        }
                      },
                    );
                  });
            },
            child: ValueListenableBuilder(
              valueListenable: _applyFormViewModel.licenseCardPath,
              builder: (context, value, child) {
                return value.isEmpty
                    ? Icon(Icons.file_upload_outlined,
                        color: MyColors.gray, size: 30.sp)
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.file(
                            height: 20.h,
                            width: 38.w,
                            File(value),
                            fit: BoxFit.contain),
                      );
              },
            ),
          ),
        ),
        verticalSpacing(20.h),
        AppTextFormField(
          validator: (value) {
            return Validators.validateNotEmpty(
                title: 'Email', value: value, context: context);
          },
          controller: widget.emailController,
          hintText: 'Enter your email',
          labelText: 'Email',
        ),
        verticalSpacing(20.h),
        AppTextFormField(
          validator: (value) {
            return Validators.validatePhoneNumber(value, context);
          },
          controller: widget.phoneNumberController,
          hintText: 'Enter your phone number',
          labelText: 'Phone',
        ),
        verticalSpacing(20.h),
        AppTextFormField(
          validator: (value) {
            return Validators.validateNID(value, context);
          },
          controller: widget.idNumberController,
          hintText: 'Enter your NID',
          labelText: 'ID Number',
        ),
        verticalSpacing(20.h),
        AppTextFormField(
          controller: widget.idImageController,
          hintText: 'Upload ID photo',
          labelText: 'ID Image',
          suffixIcon: GestureDetector(
            onTap: () {
              _showCaptureDialog();
            },
            child: ValueListenableBuilder(
              valueListenable: _applyFormViewModel.cardIdPath,
              builder: (context, value, child) {
                return value.isEmpty
                    ? Icon(Icons.file_upload_outlined,
                        color: MyColors.gray, size: 30.sp)
                    : Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.file(
                            height: 20.h,
                            width: 38.w,
                            File(value),
                            fit: BoxFit.contain),
                      );
              },
            ),
          ),
        ),
        verticalSpacing(20.h),
        Row(
          children: [
            Expanded(
              child: AppTextFormField(
                controller: widget.passwordController,
                hintText: 'Enter password',
                labelText: 'Password',
              ),
            ),
            horizontalSpacing(20.h),
            Expanded(
              child: AppTextFormField(
                controller: widget.confirmPasswordController,
                hintText: 'Confirm password',
                labelText: 'Confirm Password',
              ),
            ),
          ],
        ),
        verticalSpacing(20.h),
      ],
    );
  }

  _showCaptureDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return UploadLicenseCardDialog(
            onSaved: (imagePath) async {
              _applyFormViewModel.pickCardId(imagePath);
              if (_applyFormViewModel.cardIdPath.value.isNotEmpty) {
                final result = await _applyFormViewModel
                    .scanEgyptianIdCard(_applyFormViewModel.cardIdPath.value);

                widget.idNumberController.text =
                    await result['national_id'] ?? '';
                if (widget.idNumberController.text .isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AppLoader(),
                  );
                } else {
                  widget.idNumberController.text =
                      await result['national_id'] ?? '';
                  context.pop();
                }

                // context.pop();
              }
            },
          );
        });
  }

  _showRegisterDialog(Map<String, dynamic> result) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Apply'),
          content: Container(
            height: 200.h,
            child: Center(
              child: Column(
                children: [
                  Text('Name : ${result['name']}'),
                  verticalSpacing(5.h),
                  Text('Address : ${result['address']}'),
                  verticalSpacing(5.h),
                  Text('National ID : ${result['national_id']}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
