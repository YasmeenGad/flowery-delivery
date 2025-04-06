import 'package:auto_size_text/auto_size_text.dart';
import 'package:flowery_delivery/core/routes/app_routes.dart';
import 'package:flowery_delivery/core/services/firebase_helper/fire_store_ref_key.dart';
import 'package:flowery_delivery/core/utils/extension/media_query_values.dart';
import 'package:flowery_delivery/core/utils/extension/navigation.dart';
import 'package:flowery_delivery/core/utils/extension/string_exetension.dart';
import 'package:flowery_delivery/di/di.dart';
import 'package:flowery_delivery/features/home/presentation/viewModel/pending_order_view_model_cubit.dart';
import 'package:flowery_delivery/features/home/presentation/viewModel/pending_orders_actions.dart';
import 'package:flowery_delivery/features/home/presentation/widgets/custom_card_user_details.dart';
import 'package:flowery_delivery/features/home/presentation/widgets/custom_status_button.dart';
import 'package:flowery_delivery/features/order_details/presentation/viewModel/order_details_actions.dart';
import 'package:flowery_delivery/features/order_details/presentation/viewModel/order_details_view_model_cubit.dart';
import 'package:flowery_delivery/features/profile/domain/entities/response/get_logged_user_driver_response_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/colors/my_colors.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/widgets/spacing.dart';
import '../../domain/entities/response/pending_order_response_entity.dart';
import 'home_bloc_listener.dart';

class CustomCardOrderDetails extends StatelessWidget {
  const CustomCardOrderDetails({
    super.key,
    required this.order,
    required this.driver,
  });

  final PendingOrderResponseEntityOrders order;
  final DriverEntity driver;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MyColors.white,
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              context.translate(LangKeys.flowerOrder),
              style:
              MyFonts.styleMedium500_14.copyWith(color: MyColors.blackBase),
            ),
            verticalSpacing(16.h),
            AutoSizeText(
              context.translate(LangKeys.pickupAddress),
              style: MyFonts.styleRegular400_12.copyWith(color: MyColors.gray),
            ),
            CustomCardAddressDetails(
                title: order.store?.name ?? '',
                subtitle: order.store?.address ?? '',
                image: order.store?.image ?? ''),
            verticalSpacing(16.h),
            AutoSizeText(
              context.translate(LangKeys.deliveryAddress),
              style: MyFonts.styleRegular400_12.copyWith(color: MyColors.gray),
            ),
            CustomCardAddressDetails(
                title:
                '${order.user?.firstName ?? ''} ${order.user?.lastName ?? ''}',
                subtitle: order.user?.email ?? '',
                image: order.user?.photo!.imageFormat() ?? ''),
            verticalSpacing(16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HomeBlocListener(order: order),
                AutoSizeText("EGP ${order.totalPrice.toString()}",
                    style: MyFonts.styleSemiBold600_14
                        .copyWith(color: MyColors.blackBase)),
                CustomStatusButton(
                  statusTxt: context.translate(LangKeys.reject),
                  onPressed: () async {
                    await getIt.get<OrderDetailsViewModelCubit>()
                        .doAction(ChangeOrderStatus(
                      orderId: order.id!,
                      state: FireStoreRefKey.cancelled,
                    )).whenComplete(() {
                      Future.delayed(Durations.extralong4).whenComplete(() {
                        if(!context.mounted)return;
                        context.read<PendingOrderViewModelCubit>().onAction(
                            GetPendingOrders());
                      },);

                    },);
                  },
                ),
                CustomStatusButton(
                  statusTxt: context.translate(LangKeys.accept),
                  borderClr: Colors.transparent,
                  textColor: MyColors.white,
                  containerClr: MyColors.baseColor,
                  onPressed: () async {
                    await getIt.get<OrderDetailsViewModelCubit>().doAction(
                      AddOrderDetails(
                        order: order,
                        driver: driver,
                      ),
                    );
                    await getIt.get<OrderDetailsViewModelCubit>()
                        .doAction(UpdateOrderStatus(
                      orderId: order.id!,
                      userId: order.user!.id!,
                      status: FireStoreRefKey.accepted,
                    ));

                    await getIt.get<OrderDetailsViewModelCubit>().doAction(
                        GetOrderDetails(
                          orderId: order.id!,
                          userId: order.user!.id!,
                        )).whenComplete(() {
                      if (!context.mounted) return;
                      context.pushNamed(AppRoutes.orderDetailsView,
                          arguments: {'orderId': order.id!, 'userId': order
                              .user!.id!});
                    },);
                    debugPrint( 'user image: ${order.user!.photo}, user image format : ${order.user!.photo?.imageFormat()}');

                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
