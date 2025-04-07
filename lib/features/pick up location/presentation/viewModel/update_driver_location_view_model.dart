// update_driver_location_view_model.dart
import 'dart:async';
import 'dart:math' ;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../../../core/services/maps/polyline_service.dart';
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
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      currentLocation = await driverCurrentLocation.getLocation();
      initMarkers([ LatLng(currentLocation?.latitude ?? 0.0, currentLocation?.longitude ?? 0.0), destinationLatLng]);

      // إعدادات الموقع
      driverCurrentLocation.changeSettings(accuracy: LocationAccuracy.high, interval: 1000, distanceFilter: 1);

      // الاشتراك في التغييرات في الموقع وتحديثه
      _locationSubscription = driverCurrentLocation.onLocationChanged.listen((newLocation) async {
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

        // تحديث البيانات إلى السيرفر أو إجراء أي عمليات ضرورية
        _updateLocation(addressDetailsModel, newLocation);

        // إشعار لتحديث واجهة المستخدم
        notifyListeners();
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
    for (final elem in listLocations) {
      final polyline = await PolylineService().drawPolyline(from: location, to: elem);
      finalDistance = PolylineService.totalDistance;
      polyLinesSet.add(polyline);
    }
    notifyListeners();
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

