import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flowery_delivery/core/utils/widgets/base/snack_bar.dart';
import 'package:flowery_delivery/features/auth/domain/entities/request/apply_request_entity.dart';
import 'package:flowery_delivery/features/auth/presentation/apply/viewModel/apply_driver_actions.dart';
import 'package:flowery_delivery/features/auth/presentation/apply/viewModel/apply_driver_view_model_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowery_delivery/core/utils/widgets/base/base_view.dart';
import 'package:flowery_delivery/core/utils/widgets/base/custom_app_bar.dart';
import 'package:flowery_delivery/core/styles/fonts/my_fonts.dart';
import 'package:flowery_delivery/core/styles/colors/my_colors.dart';
import 'package:flowery_delivery/core/utils/widgets/spacing.dart';
import 'package:flowery_delivery/features/auth/presentation/apply/widgets/apply_form_fields.dart';
import 'package:flowery_delivery/features/auth/presentation/apply/widgets/gender_selection_widget.dart';
import 'package:flowery_delivery/features/auth/presentation/apply/widgets/submit_button_widget.dart';

class ApplyView extends StatefulWidget {
  const ApplyView({super.key});

  @override
  State<ApplyView> createState() => _ApplyViewState();
}

class _ApplyViewState extends State<ApplyView> {
  late final TextEditingController countryController;
  late final TextEditingController firstLegalNameController;
  late final TextEditingController secondLegalNameController;
  late final TextEditingController vechicleTypeController;
  late final TextEditingController vechicleNumberController;
  late final TextEditingController vechicleLicenseController;
  late final TextEditingController emailController;
  late final TextEditingController phoneNumberController;
  late final TextEditingController idNumberController;
  late final TextEditingController idImageController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  String? selectedGender;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    countryController = TextEditingController();
    firstLegalNameController = TextEditingController();
    secondLegalNameController = TextEditingController();
    vechicleTypeController = TextEditingController();
    vechicleNumberController = TextEditingController();
    vechicleLicenseController = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();
    idNumberController = TextEditingController();
    idImageController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    countryController.dispose();
    firstLegalNameController.dispose();
    secondLegalNameController.dispose();
    vechicleTypeController.dispose();
    vechicleNumberController.dispose();
    vechicleLicenseController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    idNumberController.dispose();
    idImageController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplyDriverViewModelCubit, ApplyDriverViewModelState>(
      listener: (context, state) {
        switch (state) {
          case ApplyDriverViewModelLoading():
            aweSnackBar(
                msg: 'Loading...',
                context: context,
                type: MessageTypeConst.help,
                title: 'Loading');
            break;
          case ApplyDriverViewModelError():
            aweSnackBar(
                msg: '${state.error.error}',
                context: context,
                type: MessageTypeConst.failure,
                title: 'Failure');
            break;
          case ApplyDriverViewModelSuccess():
            aweSnackBar(
                msg: 'Success',
                context: context,
                type: MessageTypeConst.success,
                title: 'Success');
            break;
          default:
            break;
        }
      },
      child: BaseView(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: CustomAppBar(appBarTxt: 'Apply', showArrow: true),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpacing(24.h),
                  AutoSizeText(
                    "Welcome!!",
                    style: MyFonts.styleMedium500_20
                        .copyWith(color: MyColors.blackBase),
                  ),
                  verticalSpacing(8.h),
                  AutoSizeText(
                    """You want to be a delivery man?\nJoin our team """,
                    style: MyFonts.styleMedium500_16
                        .copyWith(color: MyColors.gray),
                  ),
                  verticalSpacing(24.h),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: ApplyFormFields(
                  countryController: countryController,
                  firstLegalNameController: firstLegalNameController,
                  secondLegalNameController: secondLegalNameController,
                  vehicleTypeController: vechicleTypeController,
                  vehicleNumberController: vechicleNumberController,
                  vehicleLicenseController: vechicleLicenseController,
                  emailController: emailController,
                  phoneNumberController: phoneNumberController,
                  idNumberController: idNumberController,
                  idImageController: idImageController,
                  passwordController: passwordController,
                  confirmPasswordController: confirmPasswordController,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: GenderSelectionWidget(
                selectedGenderCallback: (gender) {
                  setState(() {
                    selectedGender = gender;
                  });
                },
              ),
            ),
            SliverToBoxAdapter(
              child: SubmitButtonWidget(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    if (selectedGender == null) {
                      return aweSnackBar(
                          msg: 'Please select a gender',
                          context: context,
                          type: MessageTypeConst.help,
                          title: 'Failure');
                    }
                    final applyData = ApplyRequestEntity(
                      country: countryController.text,
                      firstName: firstLegalNameController.text,
                      lastName: secondLegalNameController.text,
                      vehicleType: vechicleTypeController.text,
                      vehicleNumber: vechicleNumberController.text,
                      vehicleLicense: File(vechicleLicenseController.text),
                      email: emailController.text,
                      phone: phoneNumberController.text,
                      nID: idNumberController.text,
                      nIDImg: File(idImageController.text),
                      // Assuming image path or base64
                      password: passwordController.text,
                      rePassword: confirmPasswordController.text,
                      gender: selectedGender ?? '',
                    );
                    debugPrint(
                        "-----------------------${File(vechicleLicenseController.text)}");
                    debugPrint("-----------------------$selectedGender");

                    context
                        .read<ApplyDriverViewModelCubit>()
                        .onAction(ApplyDriverSubmit(applyData));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
