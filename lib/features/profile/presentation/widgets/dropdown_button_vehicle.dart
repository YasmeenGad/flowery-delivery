import 'package:flowery_delivery/core/utils/extension/media_query_values.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/colors/my_colors.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../viewModel/vehicles/vehicles_cubit.dart';

class DropdownButtonVehicle extends StatelessWidget {
  const DropdownButtonVehicle({super.key, required this.vehiclesCubit});

  final VehiclesCubit vehiclesCubit;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: vehiclesCubit.vehicleTypeController.text.isEmpty
          ? null
          : vehiclesCubit.vehicleTypeController.text,
      decoration: InputDecoration(
        hintText: context.translate(LangKeys.vehicleType),
        labelText: context.translate(LangKeys.vehicleType),
        labelStyle: MyFonts.styleRegular400_12.copyWith(color: MyColors.gray),
        hintStyle:
            MyFonts.styleRegular400_14.copyWith(color: MyColors.placeHolder),
        border: const OutlineInputBorder(),
      ),
      items: vehiclesCubit.vehicleTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type, // Display the name
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        vehiclesCubit.vehicleTypeController.text = newValue!;
      },
    );
  }
}
