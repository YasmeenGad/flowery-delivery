import 'package:flutter/material.dart';
import '../../../../core/styles/colors/my_colors.dart';

class ShadowContainerWidget extends StatelessWidget {
  const ShadowContainerWidget({super.key, this.child, this.onTap});
final Widget? child;
final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        height: null,
        decoration: BoxDecoration(
          color: MyColors.whiteBase,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: MyColors.grey.withValues(alpha: 0.25),
              spreadRadius: 0,
              blurRadius: 4,
            ),

          ],

        ),
        child: child ,
      ),
    );
  }
}
