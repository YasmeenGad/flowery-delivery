import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flowery_delivery/core/localization/lang_keys.dart';
import 'package:flowery_delivery/core/services/maps/location_helper.dart';
import 'package:flowery_delivery/core/styles/colors/my_colors.dart';
import 'package:flowery_delivery/core/styles/fonts/my_fonts.dart';
import 'package:flowery_delivery/core/utils/extension/media_query_values.dart';
import 'package:flowery_delivery/di/di.dart';
import 'package:flowery_delivery/features/auth/presentation/onBoarding/on_boarding_animation.dart';
import 'package:flowery_delivery/features/home/presentation/widgets/custom_card_order_details.dart';
import 'package:flowery_delivery/features/home/presentation/widgets/custom_text_header.dart';
import 'package:flowery_delivery/features/profile/presentation/viewModel/profile_actions.dart';
import 'package:flowery_delivery/features/profile/presentation/viewModel/profile_view_model_cubit.dart';
import 'package:flowery_delivery/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/utils/widgets/base/app_loader.dart';
import '../../../../core/utils/widgets/base/base_view.dart';
import '../viewModel/pending_order_view_model_cubit.dart';
import '../viewModel/pending_orders_actions.dart';

class PendingOrdersView extends StatefulWidget {
  const PendingOrdersView({super.key});

  @override
  State<PendingOrdersView> createState() => _PendingOrdersViewState();
}

class _PendingOrdersViewState extends State<PendingOrdersView> {
  final ProfileViewModelCubit profileViewModelCubit =
      getIt.get<ProfileViewModelCubit>();
  final indicatorController = IndicatorController();

  @override
  void initState() {
    profileViewModelCubit.doAction(GetLoggedUserData());
     LocationHelper().getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      child:
          BlocBuilder<PendingOrderViewModelCubit, PendingOrderViewModelState>(
        builder: (context, state) {
          if (state is PendingOrderViewModelLoading &&
              context.read<PendingOrderViewModelCubit>().limit == 10) {
            return AppLoader();
          } else if (state is PendingOrderViewModelLoaded) {
            return  CustomMaterialIndicator(
                onRefresh: () async {
                  context.read<PendingOrderViewModelCubit>().onAction(GetPendingOrders());
                },
                indicatorBuilder: (context,  controller) {

                  return Lottie.asset(
                    width: 50,
                    height: 50,
                    Assets.imagesFloweryLoader,
                    alignment: Alignment.bottomCenter,
                    fit: BoxFit.scaleDown,
                  );
                },
             triggerMode: IndicatorTriggerMode.anywhere,
              child: CustomScrollView(
                controller:
                    context.read<PendingOrderViewModelCubit>().scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: const CustomTextHeader(),
                    ),
                  ),
                  if (state.response.orders!.isEmpty)
                    SliverToBoxAdapter(
                      child: GestureDetector(
                        onVerticalDragDown: (details) {
                          context.read<PendingOrderViewModelCubit>().onAction(GetPendingOrders());

                        },
                        child: FadeIn(
                          duration: const Duration(milliseconds: 400),
                          child: Column(
                            children: [
                              const OnBoardingAnimation(),
                              SizedBox(
                                height: 40.sp,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: AnimatedTextKit(
                                    repeatForever: true,
                                    animatedTexts: [
                                      ScaleAnimatedText(
                                        context.translate(
                                            LangKeys.noOrdersAvailable),
                                        textStyle: MyFonts.styleBold700_24.copyWith(
                                          fontFamily: 'oronteus',
                                          color: MyColors.baseColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const  BouncingScrollPhysics(),
                      itemCount: state.response.orders!.length,
                      itemBuilder: (_, index) {
                        if (index == context.read<PendingOrderViewModelCubit>().totalItems &&
                            state is PendingOrderViewModelLoading) {
                          return Center(
                            child: SizedBox(height: 130.h, child: AppLoader()),
                          );
                        }

                        return FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: CustomCardOrderDetails(
                            order: state.response.orders![index]!,
                            driver: profileViewModelCubit.driverDataResponseEntity!.driver!,
                          ),
                        );
                      },
                    ),
                  ),

                ],
              ),
            );
          } else if (state is PendingOrderViewModelError) {
            return Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        state.errorMessage.error.toString(),
                        style: TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<PendingOrderViewModelCubit>().loadMore();
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const OnBoardingAnimation();
          }
        },
      ),
    );
  }
}
