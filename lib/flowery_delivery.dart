import 'package:flowery_delivery/core/styles/colors/my_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flowery_delivery/core/services/connectivity_controller.dart';
import 'package:flowery_delivery/core/utils/extension/media_query_values.dart';
import 'core/app_cubit/app_cubit.dart';
import 'core/app_cubit/app_state.dart';
import 'core/localization/app_localizations_setup.dart';
import 'core/routes/app_routes.dart';
import 'core/services/shared_preference/shared_pref_keys.dart';
import 'core/services/shared_preference/shared_preference_helper.dart';
import 'core/utils/screens/no_network_screen.dart';
import 'di/di.dart';
import 'features/profile/presentation/viewModel/profile_actions.dart';
import 'features/profile/presentation/viewModel/profile_view_model_cubit.dart';

class FloweryDelivery extends StatelessWidget {
  FloweryDelivery({super.key});

  final GlobalKey<NavigatorState> navigatorKey =
  getIt<GlobalKey<NavigatorState>>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ConnectivityController.instance.isConnected,
      builder: (context, value, child) {
        if (value) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                getIt<AppCubit>()
                  ..getSavedLanguage(),
              ),
              BlocProvider<ProfileViewModelCubit>(
                create: (context) => getIt.get<ProfileViewModelCubit>()..doAction(GetLoggedUserData()),
              ),
            ],
            child: ScreenUtilInit(
                child: ScreenUtilInit(
                  designSize: kIsWeb
                      ? Size(context.width, context.height)
                      : const Size(390, 844),

                  minTextAdapt: true,
                  child: BlocBuilder<AppCubit, AppStates>(
                    buildWhen: (previous, current) {
                      return previous != current;
                    },
                    builder: (context, state) {
                      final cubit = context.read<AppCubit>();
                      return MaterialApp(
                        locale: Locale(cubit.currentLanguage),
                        supportedLocales: AppLocalizationsSetup
                            .supportedLocales,
                        localeResolutionCallback:
                        AppLocalizationsSetup.localeResolutionCallback,
                        localizationsDelegates:
                        AppLocalizationsSetup.localizationsDelegates,
                        initialRoute: _getInitialRoute(),
                        debugShowCheckedModeBanner: false,
                        builder: (context, child) {
                          return Scaffold(
                            backgroundColor: MyColors.white,
                            body: Builder(
                              builder: (context) {
                                ConnectivityController.instance.init();
                                return child!;
                              },
                            ),
                          );
                        },
                        onGenerateRoute: AppRoutes.onGenerateRoute,
                        navigatorKey: getIt<GlobalKey<NavigatorState>>(),
                      );
                    },
                  ),
                )),
          );
        } else {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: NoNetworkScreen(),
          );
        }
      },
    );
  }
}

String _getInitialRoute() {
  return SharedPrefHelper().getString(key: SharedPrefKeys.tokenKey) != null
      ? AppRoutes.homeLayout
      : AppRoutes.onBoarding;
}
