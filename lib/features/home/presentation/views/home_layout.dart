import 'package:flowery_delivery/core/styles/colors/my_colors.dart';
import 'package:flowery_delivery/di/di.dart';
import 'package:flowery_delivery/features/driver_orders/presentation/viewModel/driver_order_view_model_cubit.dart';
import 'package:flowery_delivery/features/driver_orders/presentation/viewModel/driver_orders_actions.dart';
import 'package:flowery_delivery/features/driver_orders/presentation/views/driver_orders_view.dart';
import 'package:flowery_delivery/features/home/presentation/viewModel/pending_order_view_model_cubit.dart';
import 'package:flowery_delivery/features/home/presentation/viewModel/pending_orders_actions.dart';
import 'package:flowery_delivery/features/home/presentation/views/pending_orders_view.dart';
import 'package:flowery_delivery/features/profile/presentation/viewModel/profile_actions.dart';
import 'package:flowery_delivery/features/profile/presentation/viewModel/profile_view_model_cubit.dart';
import 'package:flowery_delivery/features/profile/presentation/viewModel/vehicles/vehicles_action.dart';
import 'package:flowery_delivery/features/profile/presentation/viewModel/vehicles/vehicles_cubit.dart';
import 'package:flowery_delivery/features/profile/presentation/views/profile_main_screen.dart';
import 'package:flowery_delivery/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [


      BlocProvider<PendingOrderViewModelCubit>(
        create: (context) => getIt.get<PendingOrderViewModelCubit>()
          ..onAction(GetPendingOrders()),

     child: PendingOrdersView()),
    MultiBlocProvider(providers: [

      BlocProvider<DriverOrderViewModelCubit>(
        create: (context) =>
            getIt.get<DriverOrderViewModelCubit>()..onAction(GetMyOrders()),
      )
    ], child: DriverOrdersView()),
    MultiBlocProvider(providers: [
      BlocProvider(
          create: (context) => getIt.get<ProfileViewModelCubit>()
            ..doAction(GetLoggedUserData())),
      BlocProvider(
          create: (context) =>
          getIt.get<VehiclesCubit>()..doAction(GetAllVehicles())),


    ], child: ProfileMainScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: MyColors.baseColor,
        unselectedItemColor: MyColors.white80,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage(Assets.imagesHome)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage(Assets.imagesCheckorders)),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage(Assets.imagesProfilenav)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
