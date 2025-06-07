// update_driver_location_view_model.dart
import 'dart:async';
import 'dart:math' ;

import 'package:flowery_delivery/core/services/maps/open_route_service.dart';
import 'package:flowery_delivery/core/styles/colors/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../../order_details/data/models/order_details_model.dart';
import '../../../order_details/presentation/viewModel/order_details_actions.dart';
import '../../../order_details/presentation/viewModel/order_details_view_model_cubit.dart';
import '../../data/models/address_details_model.dart';


class UpdateDriverLocationViewModel with ChangeNotifier {
  final OrderDetailsViewModelCubit viewModel;
  final Completer<GoogleMapController> mapController = Completer();

  LocationData? sourceLocation;
  LocationData? currentLocation;
  LatLng sourceLatLng = LatLng(0.0, 0.0);
  LatLng destinationLatLng = LatLng(0.0, 0.0);
  final Location location = Location();
  Location driverCurrentLocation = Location();
  Timer? _timer;
  final List<LatLng> listLocations = [];
  final Set<Polyline> polyLinesSet = {};
  double carDegree = 0.0;

  double finalDistance = 0.0;
  bool markersInitialized = false;

  StreamSubscription<LocationData>? _locationSubscription;

  UpdateDriverLocationViewModel(this.viewModel);

  _updateDriverLocation(AddressDetailsModel addressDetailsModel) {
    // تحديث الموقع بشكل دوري كل ثانية
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {

      currentLocation = await driverCurrentLocation.getLocation();
      driverCurrentLocation.changeSettings(accuracy: LocationAccuracy.navigation, interval: 1000, distanceFilter: 1);

      initMarkers([ LatLng(currentLocation!.latitude!, currentLocation!.longitude !), destinationLatLng]);

      // إعدادات الموقع

      // الاشتراك في التغييرات في الموقع وتحديثه
      _locationSubscription = driverCurrentLocation.onLocationChanged.listen((newLocation) async {
        // تحديث البيانات إلى السيرفر أو إجراء أي عمليات ضرورية
        _updateLocation(addressDetailsModel, currentLocation!);


        carDegree = newLocation.heading ?? carDegree;
        carDegree = (newLocation.heading != null && newLocation.heading! >= 0)
            ? newLocation.heading!
            : calculateDegrees(LatLng(currentLocation?.latitude ?? 0.0, currentLocation?.longitude ?? 0.0), LatLng(newLocation.latitude!, newLocation.longitude!));

        // تحديث الكاميرا مع الموقع الجديد
        if (mapController.isCompleted) {
          final controller = await mapController.future;
          await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(newLocation.latitude!, newLocation.longitude!),
            zoom: 14.5,
            tilt: 100,
            bearing: 0,
          )));
          currentLocation = newLocation;
          notifyListeners();
        }


      });
    });
    notifyListeners();
  }

  Future<void> getCurrentLocation(AddressDetailsModel addressDetailsModel) async {
    try {
      final userLocation = await location.getLocation();
      sourceLocation = userLocation;
      destinationLatLng = addressDetailsModel.isPickup
          ? LatLng(addressDetailsModel.storeLocation.latitude, addressDetailsModel.storeLocation.longitude)
          : LatLng(addressDetailsModel.userLocation.latitude, addressDetailsModel.userLocation.longitude);

      sourceLatLng = LatLng(userLocation.latitude!, userLocation.longitude!);
      _updateDriverLocation(addressDetailsModel);
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      sourceLocation = null;
    }
  }

  Future<void> initMarkers(List<LatLng> locations) async {
    listLocations.clear();
    polyLinesSet.clear();
    listLocations.addAll(locations);
    await drawPolyLine(listLocations[0]);

  }

  void _updateLocation(AddressDetailsModel addressDetailsModel, LocationData locationData) {
    debugPrint(' update order details location view model =>>> $locationData');

    viewModel.doAction(UpdateLocation(
      userId: addressDetailsModel.userId,
      orderId: addressDetailsModel.orderId,
      location: LocationModel(
        latitude: locationData.latitude,
        longitude: locationData.longitude,
      ),
    ));

  }

  Future<void> drawPolyLine(LatLng location) async {
    debugPrint('🟡 Source: ${sourceLatLng.latitude}, ${sourceLatLng.longitude}');
    debugPrint('🟡 Destination: ${destinationLatLng.latitude}, ${destinationLatLng.longitude}');
    // try {
    //   for (final elem in listLocations) {
    //     final polyline = await PolylineService().drawPolyline(from: location, to: elem);
    //     finalDistance = PolylineService.totalDistance;
    //     polyLinesSet.add(polyline);
    //   }
    //   if (!hasListeners) return;
    //   notifyListeners();
    // } catch (e) {
    //   debugPrint('❌ Failed to draw polyline: $e');
    // }
    debugPrint('🟡 Source: ${location.latitude}, ${location.longitude}');
    debugPrint('🟡 Destination: ${destinationLatLng.latitude}, ${destinationLatLng.longitude}');
    try {
      final service = OpenRouteService();
      final route = await service.getRouteCoordinates(start: location, end: destinationLatLng);

      final polyline = Polyline(
        polylineId:  PolylineId('polyline_${DateTime.now().millisecondsSinceEpoch}'),
        color: MyColors.baseColor,
        width: 4,
        points: route,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.bevel,
        geodesic: true,
      );

      finalDistance = await service.getDistanceInKm(start: location, end: destinationLatLng);
      polyLinesSet.clear();
      polyLinesSet.add(polyline);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to draw polyline: $e');
    }

  }


  static double calculateDegrees(LatLng startPoint, LatLng endPoint) {
    final double startLat = toRadians(startPoint.latitude);
    final double startLng = toRadians(startPoint.longitude);
    final double endLat = toRadians(endPoint.latitude);
    final double endLng = toRadians(endPoint.longitude);

    final double deltaLng = endLng - startLng;
    final double y = sin(deltaLng) * cos(endLat);
    final double x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(deltaLng);
    final double bearing = atan2(y, x);
    return (toDegrees(bearing) + 360) % 360;
  }

  static double toRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  static double toDegrees(double radians) {
    return radians * (180.0 / pi);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _timer?.cancel(); // تأكد من إلغاء الـ timer عند التخلص من الـ ViewModel
    super.dispose();
  }
}

