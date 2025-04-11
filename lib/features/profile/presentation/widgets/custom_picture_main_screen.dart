// ignore_for_file: unnecessary_null_comparison

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../generated/assets.dart';

class CustomPictureMainScreen extends StatefulWidget {
  const CustomPictureMainScreen({super.key, required this.image});
 final String image;
  @override
  State<CustomPictureMainScreen> createState() =>
      _CustomPictureMainScreenState();
}

class _CustomPictureMainScreenState extends State<CustomPictureMainScreen> {


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      width: 70.w,
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.antiAlias,
        children: [
          widget.image == null
              ? const CircleAvatar(
            backgroundImage: AssetImage(Assets.imagesProfile),
          )
              : CircleAvatar(
    backgroundImage: CachedNetworkImageProvider(widget.image),),
        ],
      ),
    );
  }
}
