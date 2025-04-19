import 'package:flowery_delivery/core/networking/common/api_result.dart';
import 'package:flowery_delivery/features/order_details/data/data_sources/contracts/order_details_online_data_source.dart';
import 'package:flowery_delivery/features/order_details/data/models/order_details_model.dart';
import 'package:flowery_delivery/features/order_details/domain/entities/order_details_entity.dart';
import 'package:flowery_delivery/features/order_details/domain/repositories/contract/order_details_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: OrderDetailsRepo)
class OrderDetailsRepoImpl implements OrderDetailsRepo {
  final OrderDetailsOnlineDataSource _dataSource;

  @factoryMethod
  OrderDetailsRepoImpl(this._dataSource);

  @override
  Future<DataResult<void>> addOrderDetails({required OrderDetailsEntity orderDetails}) async {
    return _dataSource.addOrderDetails(orderDetails: orderDetails);
  }

  @override
  Stream<DataResult<OrderDetailsEntity>> getOrderByOrderId( { required String userId ,required String orderId}) {
    return _dataSource.getOrderByOrderId(userId:  userId,orderId: orderId);
  }

  @override
  Future<DataResult<void>> updateOrderStatus({required String userId ,required String orderId, required String status}) {
    return _dataSource.updateOrderStatus(userId: userId, orderId: orderId, status: status);
  }

  @override
  Future<DataResult<void>> statOrder({required String orderId}) {
    return _dataSource.statOrder(orderId: orderId);
  }

  @override
  Future<DataResult<void>> changeOrderStatus({required String orderId, required String state}) {
    return _dataSource.changeOrderStatus(orderId: orderId, state: state);
  }

  @override
  Future<DataResult<void>> updateLocation(
      {required String orderId,
      required String userId,
      required LocationModel location}) async {

    debugPrint(' update order details location =>>> ${location.toJson()}');

    return await _dataSource.updateLocation(
        orderId: orderId, useId: userId, location: location);
  }
}
