import 'package:flowery_delivery/core/styles/colors/my_colors.dart';
import 'package:flowery_delivery/core/utils/extension/media_query_values.dart';
import 'package:flowery_delivery/core/utils/extension/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/widgets/buttons/carved_button.dart';
import '../../../../generated/assets.dart';

class SuccessView extends StatelessWidget {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20.h,
        children: [
          SvgPicture.asset(
            Assets.imagesSuccessImg,
            width: 150.w,
            height: 150.h,
            fit: BoxFit.fill,
          ),
          SizedBox(
              width: 200.w,
              child: Text(
                context.translate(LangKeys.thankYou),
                style: MyFonts.styleBold700_24.copyWith(color: MyColors.green),
                textAlign: TextAlign.center,
              )),
          SizedBox(
              width: 300.w,
              child: Text(
                context.translate(LangKeys.theOrderDeliveredSuccessfully),
                style: MyFonts.styleBold700_24,
                textAlign: TextAlign.center,
              )),
          CurvedButton(
            title: context.translate(LangKeys.done),
            onTap: () async {
              await context.pushReplacementNamed(AppRoutes.pendingOrdersView);
            },
          )
        ],
      ),
    );
  }
}
