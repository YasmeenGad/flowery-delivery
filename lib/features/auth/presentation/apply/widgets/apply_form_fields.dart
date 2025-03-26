import 'dart:io';

import 'package:flowery_delivery/features/auth/presentation/apply/widgets/upload_license_card_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flowery_delivery/core/utils/widgets/app_text_form_field.dart';
import 'package:flowery_delivery/core/utils/widgets/spacing.dart';
import 'package:flowery_delivery/core/styles/colors/my_colors.dart';
import '../../../../../core/utils/validators.dart';
import '../viewModel/apply_form_view_model.dart';

class ApplyFormFields extends StatefulWidget {
  final TextEditingController countryController;
  final TextEditingController firstLegalNameController;
  final TextEditingController secondLegalNameController;
  final TextEditingController vechicleTypeController;
  final TextEditingController vechicleNumberController;
  final TextEditingController vechicleLicenseController;
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
    required this.vechicleTypeController,
    required this.vechicleNumberController,
    required this.vechicleLicenseController,
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
          widget.vechicleLicenseController.text = pickedFile.path;
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
              style: TextStyle(fontSize: 12.sp,overflow: TextOverflow.ellipsis)),
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
          controller: widget.vechicleTypeController,
          hintText: 'Enter vehicle type',
          labelText: 'Vehicle Type',
        ),
        verticalSpacing(20.h),
        AppTextFormField(
          validator: (value) {
            return Validators.validateNotEmpty(
                title: 'Vehicle Number', value: value, context: context);
          },
          controller: widget.vechicleNumberController,
          hintText: 'Enter vehicle number',
          labelText: 'Vehicle Number',
        ),
        verticalSpacing(20.h),
        AppTextFormField(
          controller: widget.vechicleLicenseController,
          hintText: 'Upload license photo',
          labelText: 'Vehicle License',
          suffixIcon: GestureDetector(
            onTap: (){
              showDialog(context: context, builder: (context) {
                return UploadLicenseCardDialog();
              });

            },
            child: _applyFormViewModel.imagePath.isEmpty?Icon(
              Icons.file_upload_outlined,
              color: MyColors.gray,
              size: 30.sp,
            ):Image.file(File(_applyFormViewModel.imagePath),width: 30.sp,height: 30.sp,),
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
            onTap: _pickImageForId,
            child: Icon(
              Icons.file_upload_outlined,
              color: MyColors.gray,
              size: 30.sp,
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
}
