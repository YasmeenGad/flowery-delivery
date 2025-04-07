import 'package:bloc/bloc.dart';
import 'package:flowery_delivery/core/networking/common/api_result.dart';
import 'package:flowery_delivery/core/networking/error/error_handler.dart';
import 'package:flowery_delivery/core/networking/error/error_model.dart';
import 'package:flowery_delivery/core/routes/app_routes.dart';
import 'package:flowery_delivery/core/services/firebase_helper/fire_store_ref_key.dart';
import 'package:flowery_delivery/core/services/firebase_notification/notification_helper.dart';
import 'package:flowery_delivery/features/order_details/data/mappers/order_details_mapper.dart';
import 'package:flowery_delivery/features/order_details/domain/entities/order_details_entity.dart';
import 'package:flowery_delivery/features/order_details/domain/use_cases/add_order_details_case.dart';
import 'package:flowery_delivery/features/order_details/domain/use_cases/change_order_status.dart';
import 'package:flowery_delivery/features/order_details/domain/use_cases/get_order_by_order_id_case.dart';
import 'package:flowery_delivery/features/order_details/domain/use_cases/update_driver_location.dart';
import 'package:flowery_delivery/features/order_details/domain/use_cases/update_order_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

import 'order_details_actions.dart';

part 'order_details_view_model_state.dart';

@injectable
class OrderDetailsViewModelCubit extends Cubit<OrderDetailsViewModelState> {
  final AddOrderDetailsCase addOrderDetailsCase;
  final GetOrderByOrderIdCase getOrderByOrderIdCase;

  final UpdateOrderStatusCase updateOrderStatusCase;
  final ChangeOrderStatusCase changeOrderStatusCase;
  final UpdateDriverLocationUseCase updateDriverLocationUseCase;

  OrderDetailsViewModelCubit(
      this.addOrderDetailsCase,
      this.updateDriverLocationUseCase,
      this.getOrderByOrderIdCase,
      this.updateOrderStatusCase,
      this.changeOrderStatusCase)
      : super(OrderDetailsViewModelInitial());
  var orderStatus = (
    step: 1,
    name: "Arrived at Pickup Point",
    action: FireStoreRefKey.accepted,
    notificationTitle: "📦 Order Accepted",
    notificationBody: "Your order has been accepted by the store",
  );
  OrderDetailsEntity? orderDetailsEntity;

  Future<void> doAction(OrderDetailsActions action) async {
    switch (action) {
      case AddOrderDetails():
        await _addOrderDetails(action);
      case GetOrderDetails():
        await _getOrderDetails(action);
      case UpdateOrderStatus():
        _updateOrderStatus(action);
      case ChangeOrderStatus():
        _changeOrderStatus(action);
      case UpdateLocation():
        _updateLocation(action);
    }
  }

  Future<void> _addOrderDetails(AddOrderDetails action) async {
    emit(OrderDetailsViewModelLoading());

    final result = await addOrderDetailsCase(
        orderDetails: OrderDetailsEntity(
            driver: OrderDetailsMapper.toDriverData(action.driver),
            orders: OrderDetailsMapper.toOrderData(action.order)));
    switch (result) {
      case Success<void>():
        NotificationHelper().sendNotification(
          title: orderStatus.notificationTitle,
          body: orderStatus.notificationBody,
          topic: action.order.id,
          data: {"route": AppRoutes.trackOrder, "orderId": action.order.id!, "userId": action.order.user!.id!},
          // orderId: action.order.id,
          // userId: action.order.user!.id,
        );
        emit(AddOrderSuccess());

      case Fail<void>():
        emit(
            OrderDetailsViewModelError(ErrorHandler.handle(result.exception!)));
    }
  }

  Future<void> _getOrderDetails(GetOrderDetails action) async {
    emit(OrderDetailsViewModelLoading());
    final resultStream = await getOrderByOrderIdCase(
        orderId: action.orderId, userId: action.userId);
    resultStream.listen((result) {
      switch (result) {
        case Success<OrderDetailsEntity>():
          orderDetailsEntity = result.data;
          debugPrint(' order details ${result.data.orders}');
          emit(GetOrderDetailsSuccess(result.data));
        case Fail<OrderDetailsEntity>():
          emit(OrderDetailsViewModelError(
              ErrorHandler.handle(result.exception!)));
      }
    });
  }

  Future<void> _updateOrderStatus(UpdateOrderStatus action) async {
    emit(OrderDetailsViewModelLoading());
    final result = await updateOrderStatusCase(
        userId: action.userId, orderId: action.orderId, status: action.status);
    switch (result) {
      case Success<void>():
        debugPrint(' order status updated ${action.status}');
        emit(UpdateOrderStatusSuccess());
      case Fail<void>():
        emit(
            OrderDetailsViewModelError(ErrorHandler.handle(result.exception!)));
    }
  }

  Future<void> _changeOrderStatus(ChangeOrderStatus action) async {
    emit(OrderDetailsViewModelLoading());
    final result = await changeOrderStatusCase(
        orderId: action.orderId, state: action.state);
    switch (result) {
      case Success<void>():
        debugPrint(' order status updated ${action.state}');

        emit(ChangeOrderStatusSuccess());
      case Fail<void>():
        emit(
            OrderDetailsViewModelError(ErrorHandler.handle(result.exception!)));
    }
  }

  updateOrderStatus(OrderDetailsEntity orderDetailsEntity) {
    switch (orderDetailsEntity.orders!.state!) {
      case FireStoreRefKey.accepted:
        debugPrint(' order status name ${orderStatus.name}');
        orderStatus = (
          step: 2,
          name: "Start Delivery",
          action: FireStoreRefKey.picked,
          notificationTitle: "🚚 Delivery Started",
          notificationBody: "Your order is on the way",
        );

      case FireStoreRefKey.picked:
        orderStatus = (
          step: 3,
          name: "Arrived to The User",
          action: FireStoreRefKey.outForDelivery,
          notificationTitle: "🏠 Arrived to The User",
          notificationBody: "Your order has arrived to the user",
        );

      case FireStoreRefKey.outForDelivery:
        orderStatus = (
          step: 4,
          name: "Arrived at The Destination",
          action: FireStoreRefKey.arrived,
          notificationTitle: "📍 Arrived at The Destination",
          notificationBody: "Your order has arrived at the destination",
        );

      case FireStoreRefKey.arrived:
        orderStatus = (
          step: 5,
          name: "Delivered",
          action: FireStoreRefKey.delivered,
          notificationTitle: "✅ Order Delivered",
          notificationBody: "Your order has been delivered",
        );
    }

    emit(UpdateStatus());
  }

  Future<void> _updateLocation(UpdateLocation action) async {
    final result = await updateDriverLocationUseCase.execute(
        orderId: action.orderId,
        userId: action.userId,
      location: action.location,
    );
    switch (result) {
      case Success<void>():
        emit(UpdateLocationSuccess());
        break;
      case Fail<void>():
        emit(UpdateLocationError("can't update location"));
        break;
    }
  }



}

enum OrderStatus { accepted, picked, outForDelivery, arrived, delivered }
