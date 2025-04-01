// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_order_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverOrderResponseDto _$DriverOrderResponseDtoFromJson(
        Map<String, dynamic> json) =>
    DriverOrderResponseDto(
      json['message'] as String?,
      json['metadata'] == null
          ? null
          : DriverOrderMetadataDto.fromJson(
              json['metadata'] as Map<String, dynamic>),
      (json['orders'] as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : DriverOrdersListDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );


DriverOrderMetadataDto _$DriverOrderMetadataDtoFromJson(
        Map<String, dynamic> json) =>
    DriverOrderMetadataDto(
      (json['currentPage'] as num?)?.toInt(),
      (json['totalPages'] as num?)?.toInt(),
      (json['totalItems'] as num?)?.toInt(),
      (json['limit'] as num?)?.toInt(),
    );


DriverOrdersListDto _$DriverOrdersListDtoFromJson(Map<String, dynamic> json) =>
    DriverOrdersListDto(
      json['_id'] as String?,
      json['driver'] as String?,
      json['order'] == null
          ? null
          : DriverOrderDto.fromJson(json['order'] as Map<String, dynamic>),
      (json['__v'] as num?)?.toInt(),
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['store'] == null
          ? null
          : DriverStoreDto.fromJson(json['store'] as Map<String, dynamic>),
    );


DriverOrderDto _$DriverOrderDtoFromJson(Map<String, dynamic> json) =>
    DriverOrderDto(
      json['_id'] as String?,
      json['user'] == null
          ? null
          : DriverUserDto.fromJson(json['user'] as Map<String, dynamic>),
      (json['orderItems'] as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : DriverOrderItemsDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['totalPrice'] as num?)?.toInt(),
      json['paymentType'] as String?,
      json['isPaid'] as bool?,
      json['isDelivered'] as bool?,
      json['state'] as String?,
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['orderNumber'] as String?,
      (json['__v'] as num?)?.toInt(),
    );


DriverUserDto _$DriverUserDtoFromJson(Map<String, dynamic> json) =>
    DriverUserDto(
      json['_id'] as String?,
      json['firstName'] as String?,
      json['lastName'] as String?,
      json['email'] as String?,
      json['gender'] as String?,
      json['phone'] as String?,
      json['photo'] as String?,
    );


DriverOrderItemsDto _$DriverOrderItemsDtoFromJson(Map<String, dynamic> json) =>
    DriverOrderItemsDto(
      json['product'] == null
          ? null
          : DriverOrderItemsProductDto.fromJson(
              json['product'] as Map<String, dynamic>),
      (json['price'] as num?)?.toInt(),
      (json['quantity'] as num?)?.toInt(),
      json['_id'] as String?,
    );


DriverOrderItemsProductDto _$DriverOrderItemsProductDtoFromJson(
        Map<String, dynamic> json) =>
    DriverOrderItemsProductDto(
      json['_id'] as String?,
      (json['price'] as num?)?.toInt(),
    );


DriverStoreDto _$DriverStoreDtoFromJson(Map<String, dynamic> json) =>
    DriverStoreDto(
      json['name'] as String?,
      json['image'] as String?,
      json['address'] as String?,
      json['phoneNumber'] as String?,
      json['latLong'] as String?,
    );

