import 'package:json_annotation/json_annotation.dart';

part 'cart_item.g.dart';

@JsonSerializable()
class CartItem {
  final String title;
  final double price;
  final double gst;
  final double serviceCharges;
  final double totalPrice;

  CartItem({
    required this.title,
    required this.price,
    required this.gst,
    required this.serviceCharges,
    required this.totalPrice,
  });
  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}
