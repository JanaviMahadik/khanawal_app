// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      gst: (json['gst'] as num).toDouble(),
      serviceCharges: (json['serviceCharges'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
      'title': instance.title,
      'price': instance.price,
      'gst': instance.gst,
      'serviceCharges': instance.serviceCharges,
      'totalPrice': instance.totalPrice,
    };
