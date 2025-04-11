// ignore_for_file: library_private_types_in_public_api

import 'package:flowery_delivery/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flowery_delivery/core/styles/colors/my_colors.dart';
import 'package:flowery_delivery/di/di.dart';
import 'package:flowery_delivery/features/order_details/presentation/viewModel/order_details_view_model_cubit.dart';
import 'package:flowery_delivery/features/pick%20up%20location/presentation/widgets/delivery_location.dart';
import '../../../../core/utils/widgets/base/snack_bar.dart';
import '../../data/models/address_details_model.dart';
import '../viewModel/update_driver_location_view_model.dart';
import '../widgets/arrow_back_button.dart';
import '../widgets/custom_address_details.dart';

class LocationView extends StatefulWidget {
  final AddressDetailsModel addressDetailsModel;

  const LocationView({super.key, required this.addressDetailsModel});

  @override
  _LocationViewState createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  final MapController mapController = MapController();
  late final OrderDetailsViewModelCubit viewModel;
  late final UpdateDriverLocationViewModel locationViewModel;

  @override
  void initState() {
    super.initState();
    viewModel = getIt<OrderDetailsViewModelCubit>();
    locationViewModel = UpdateDriverLocationViewModel(viewModel);
    locationViewModel.getCurrentLocation(widget.addressDetailsModel);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => locationViewModel),
        BlocProvider(create: (context) => viewModel),
      ],
      child: Stack(
        children: [
          BlocListener<OrderDetailsViewModelCubit, OrderDetailsViewModelState>(
            listener: (context, state) {
              switch (state) {
                case UpdateLocationError():
                  aweSnackBar(
                      title: 'Failed',
                      msg: state.errorMessage,
                      context: context,
                      type: MessageTypeConst.failure);
                  break;
                default:
                  null;
              }
            },
            child: Consumer<UpdateDriverLocationViewModel>(
              builder: (context, state, child) {
                if (state.currentLocation == null) {
                  return Center(
                    child: SpinKitThreeInOut(
                      color: MyColors.baseColor,
                      size: 40.0,
                    ),
                  );
                }
                LatLng currentLatLng = LatLng(
                  state.currentLocation!.latitude!,
                  state.currentLocation!.longitude!,
                );
                LatLng destinationLatLng = widget.addressDetailsModel.isPickup
                    ? LatLng(widget.addressDetailsModel.storeLocation.latitude,
                        widget.addressDetailsModel.storeLocation.longitude)
                    : LatLng(widget.addressDetailsModel.userLocation.latitude,
                        widget.addressDetailsModel.userLocation.longitude);

                return Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: currentLatLng,
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 115,
                                height: 35,
                                point: currentLatLng,
                                child: DeliveryLocation(
                                  color: MyColors.baseColor,
                                  icon: Icon(Icons.location_on_outlined),
                                  title: 'Your Location',
                                ),
                              ),
                              Marker(
                                  width: 95,
                                  height: 32,
                                  point: destinationLatLng,
                                  child: DeliveryLocation(
                                    color: MyColors.white,
                                    title: widget.addressDetailsModel.isPickup
                                        ? 'Flowery'
                                        : 'User',
                                    icon: Image.asset(
                                      Assets.imagesFloweryLogo,
                                      width: 30,
                                      height: 30,
                                    ),
                                    isDestination: true,
                                  )),
                            ],
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [currentLatLng, destinationLatLng],
                                strokeWidth: 4.0,
                                color: MyColors.baseColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: CustomAddressDetails(
                        addressDetailsModel: widget.addressDetailsModel,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            top: 40.h,
            left: 16.w,
            child: const ArrowBackButton(),
          ),
        ],
      ),
    );
  }
}
