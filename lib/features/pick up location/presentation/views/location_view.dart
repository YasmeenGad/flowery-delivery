// location_view.dart (Refactored)
// ignore_for_file: library_private_types_in_public_api

import 'package:animate_do/animate_do.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flowery_delivery/core/styles/colors/my_colors.dart';
import 'package:flowery_delivery/di/di.dart';
import 'package:flowery_delivery/features/order_details/presentation/viewModel/order_details_view_model_cubit.dart';
import 'package:flowery_delivery/features/pick%20up%20location/presentation/widgets/delivery_location.dart';
import 'package:flowery_delivery/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

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
  void dispose() {
    locationViewModel.dispose();
    super.dispose();
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
              if (state is UpdateLocationError) {
                aweSnackBar(
                  title: 'Failed',
                  msg: state.errorMessage,
                  context: context,
                  type: MessageTypeConst.failure,
                );
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

                return Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomGoogleMapMarkerBuilder(
                        customMarkers: [
                          MarkerData(
                            marker: Marker(
                              markerId: const MarkerId('source'),
                              position: state.sourceLatLng,
                            ),
                            child: DeliveryLocation(
                              color: MyColors.baseColor,
                              icon: Icon(Icons.location_on_outlined,
                                  color: MyColors.baseColor),
                              title: 'Your Location',
                            ),
                          ),
                          MarkerData(
                            marker: Marker(
                              markerId: const MarkerId('destination'),
                              position: state.destinationLatLng,
                            ),
                            child: DeliveryLocation(
                              color: MyColors.baseColor,
                              icon: widget.addressDetailsModel.isPickup
                                  ? Image.asset(Assets.imagesFlowery,
                                      width: 30, height: 30)
                                  : Icon(Icons.home_outlined,
                                      color: MyColors.baseColor),
                              isDestination: false,
                              title: widget.addressDetailsModel.isPickup
                                  ? 'Flowery'
                                  : 'User',
                            ),
                          ),
                          if (state.currentLocation != null)
                            MarkerData(
                              marker: Marker(
                                markerId: const MarkerId('current'),
                                position: LatLng(
                                  state.currentLocation!.latitude!,
                                  state.currentLocation!.longitude!,
                                ),
                                anchor: Offset(0.5, 0.5),
                                infoWindow: InfoWindow(
                                  title:
                                      'Speed :${state.currentLocation!.speed?.toStringAsFixed(2)} km/h '
                                      '\n Accuracy: ${state.currentLocation!.speedAccuracy?.toStringAsFixed(2)} m/s '
                                      '\n Remain Distance: ${state.finalDistance.toStringAsFixed(2)} m',
                                  snippet: state.currentLocation!.speedAccuracy?.toStringAsFixed(2)
                                      .toString(),
                                ),
                                rotation: state.carDegree,
                              ),
                              child: FadeInDown(
                                duration: const Duration(seconds: 1),
                                child: Image.asset(
                                  Assets.imagesMotorcycleDelivery,
                                  width: 100.w,
                                  height: 100.h,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                        ],
                        builder: (BuildContext context, Set<Marker>? markers) {
                          return GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: state.sourceLatLng,
                              zoom: 14.0,
                            ),
                            mapType: MapType.terrain,
                            markers: markers ?? {},
                            polylines: state.polyLinesSet,
                            onMapCreated:
                                (GoogleMapController mapController) async {
                              if (!state.mapController.isCompleted) {
                                state.mapController.complete(mapController);
                              }
                            },
                            zoomControlsEnabled: true,
                            zoomGesturesEnabled: true,
                          );
                        },
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
