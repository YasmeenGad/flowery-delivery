import 'package:flowery_delivery/core/utils/screens/under_build_screen.dart';
import 'package:flowery_delivery/di/di.dart';
import 'package:flowery_delivery/features/App_approve/presentation/views/success_apply_view.dart';
import 'package:flowery_delivery/features/auth/presentation/apply/viewModel/apply_driver_view_model_cubit.dart';
import 'package:flowery_delivery/features/order_details/presentation/views/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flowery_delivery/features/auth/presentation/onBoarding/on_boarding.dart';
import 'package:flowery_delivery/features/driver_orders/domain/entities/response/driver_order_entity.dart';
import 'package:flowery_delivery/features/driver_orders/presentation/views/driver_order_details_screen.dart';
import 'package:flowery_delivery/features/home/presentation/viewModel/pending_order_view_model_cubit.dart';
import 'package:flowery_delivery/features/order_details/presentation/viewModel/order_details_actions.dart';
import 'package:flowery_delivery/features/order_details/presentation/viewModel/order_details_view_model_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/apply/views/apply_view.dart';
import '../../features/auth/presentation/forget_password/ViewModel/forget_password_view_model_cubit.dart';
import '../../features/auth/presentation/forget_password/view/email_verification.dart';
import '../../features/auth/presentation/forget_password/view/forget_password.dart';
import '../../features/auth/presentation/forget_password/view/reset_password.dart';
import '../../features/auth/presentation/login/view/login_view.dart';
import '../../features/home/presentation/viewModel/pending_orders_actions.dart';
import '../../features/home/presentation/views/home_layout.dart';
import '../../features/home/presentation/views/pending_orders_view.dart';
import '../../features/pick up location/data/models/address_details_model.dart';
import '../../features/pick up location/presentation/views/location_view.dart';
import '../../features/profile/presentation/viewModel/edit_profile/edit_profile_cubit.dart';
import '../../features/profile/presentation/viewModel/profile_actions.dart';
import '../../features/profile/presentation/viewModel/profile_view_model_cubit.dart';
import '../../features/profile/presentation/viewModel/vehicles/vehicles_action.dart';
import '../../features/profile/presentation/viewModel/vehicles/vehicles_cubit.dart';
import '../../features/profile/presentation/views/profile_main_screen.dart';
import '../../features/profile/presentation/views/profile_view.dart';
import '../../features/profile/presentation/views/reset_password_profile_view.dart';
import '../../features/profile/presentation/views/vehicle_view.dart';
import '../../features/success page/presentation/views/success_view.dart';
import 'base_routes.dart';

class AppRoutes {
  static const String onBoarding = '/';
  static const String login = 'login';
  static const String forgetPassword = 'forgetPassword';
  static const String emailVerification = 'emailVerification';
  static const String resetPassWord = 'resetPassWord';
  static const String changePassWord = 'changePassWord';
  static const String homeLayout = 'homeLayout';
  static const String applyView = 'applyView';
  static const String successApplyView = 'successApplyView';
  static const String profileMainScreen = 'profileMainScreen';
  static const String profileView = "profileView";
  static const String vehicleView = "vehicleView";
  static const String pendingOrdersView = "pendingOrdersView";
  static const String resetPasswordProfileView = "resetPasswordProfileView";
  static const String orderDetailsView = "orderDetailsView";
  static const String locationView = "locationView";
  static const String driverOrderDetailsView = "driverOrderDetailsView";
  static const String trackOrder = 'trackOrder';
  static const String successView = "successView";

  static Route<void> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case applyView:
        return BaseRoute(
            page: BlocProvider<ApplyDriverViewModelCubit>(
                create: (context) => getIt.get<ApplyDriverViewModelCubit>(),
                child: const ApplyView()));
      case homeLayout:
        return BaseRoute(
            page: MultiBlocProvider(providers: [
          BlocProvider(
              create: (context) => getIt.get<ProfileViewModelCubit>()
                ..doAction(GetLoggedUserData())),
          BlocProvider<PendingOrderViewModelCubit>(
            create: (context) => getIt.get<PendingOrderViewModelCubit>()
              ..onAction(GetPendingOrders()),
          ),
          BlocProvider<OrderDetailsViewModelCubit>(
            create: (context) => getIt.get<OrderDetailsViewModelCubit>(),
          ),
          BlocProvider(
              create: (context) =>
                  getIt.get<VehiclesCubit>()..doAction(GetAllVehicles())),
        ], child: const HomeLayout()));
      case AppRoutes.onBoarding:
        return BaseRoute(
          page: const OnBoarding(),
        );
      case AppRoutes.login:
        return BaseRoute(
          page: const LoginView(),
        );
         case successApplyView:
        return BaseRoute(page: const SuccessApplyView());
      case AppRoutes.forgetPassword:
        return BaseRoute(
          page: BlocProvider(
              create: (context) => getIt.get<ForgetPasswordViewModelCubit>(),
              child: ForgetPassword()),
        );
      case AppRoutes.emailVerification:
        return BaseRoute(
            page: BlocProvider(
          create: (context) => getIt.get<ForgetPasswordViewModelCubit>(),
          child: EmailVerification(args as String),
        ));

      case AppRoutes.resetPassWord:
        return BaseRoute(
          page: BlocProvider(
              create: (context) => getIt.get<ForgetPasswordViewModelCubit>(),
              child: ResetPassword()),
        );
      case AppRoutes.profileMainScreen:
        return BaseRoute(
          page: ProfileMainScreen(),
        );
      case AppRoutes.profileView:
        return BaseRoute(page: const ProfileView());
      case AppRoutes.vehicleView:
        return BaseRoute(
            page: MultiBlocProvider(providers: [
          BlocProvider<ProfileViewModelCubit>(
            create: (context) => getIt.get<ProfileViewModelCubit>()
              ..doAction(GetLoggedUserData()),
          ),
          BlocProvider<VehiclesCubit>(
            create: (context) =>
                getIt.get<VehiclesCubit>()..doAction(GetAllVehicles()),
          ),
          BlocProvider<EditProfileCubit>(
            create: (context) => getIt.get<EditProfileCubit>(),
          ),
        ], child: const VehicleView()));
      case AppRoutes.resetPasswordProfileView:
        return BaseRoute(page: const ResetPasswordProfileView());
      case AppRoutes.pendingOrdersView:
        return BaseRoute(
            page: BlocProvider<PendingOrderViewModelCubit>(
              create: (context) =>
              getIt.get<PendingOrderViewModelCubit>()
                ..onAction(GetPendingOrders()),
              child: const PendingOrdersView(),
        ));
      case AppRoutes.locationView:
        final arguments = settings.arguments as AddressDetailsModel?;
        return BaseRoute(
          page: LocationView(
            addressDetailsModel: arguments!, // Pass the arguments to the screen
          ),
        );
      case AppRoutes.orderDetailsView:
        final arguments = settings.arguments as Map<String, String>?;
        return BaseRoute(
            page: BlocProvider(
              create: (context) => getIt.get<OrderDetailsViewModelCubit>()
                ..doAction(GetOrderDetails(
                    orderId: arguments!['orderId']!, userId: arguments['userId']!)),
              child: OrderDetailsScreen(),
            ));
        case AppRoutes.driverOrderDetailsView:
          return BaseRoute(
              page: BlocProvider(
                create: (context) => getIt.get<OrderDetailsViewModelCubit>()
                  // ..doAction(GetDriverOrderDetails(
                  //     orderId: driverArgs!['orderId']!, userId: driverArgs['userId']!))
                ,
                child: DriverOrderDetailsScreen(order: args as DriverOrderList,),
              ));
      case AppRoutes.successView:
        return BaseRoute(page: const SuccessView());
      default:
        return BaseRoute(page: const PageUnderBuildScreen());
    }
  }
}
