import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }
  final String authToken;
  final String userId;
  
  Orders(this.authToken, this.userId, this._orders);

  final baseUrl =
      'https://shopping-demo-cd112.firebaseio.com/orders';

  Future<void> fetchAndSetOrders() async {
    final response = await http.get("$baseUrl/$userId.json?auth=$authToken");
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) return;

    extractedData.forEach((key, value) {
      loadedOrders.add(
        OrderItem(
          id: key,
          amount: value['amount'],
          dateTime: DateTime.parse(value['dateTime']),
          products: (value['products'] as List<dynamic>)
              .map(
                (e) => CartItem(
                  id: e['id'],
                  title: e['title'],
                  quantity: e['quantity'],
                  price: e['price'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timestamp = DateTime.now();
    try {
      final response = await http.post("$baseUrl/$userId.json?auth=$authToken",
          body: json.encode({
            'amount': total,
            'dateTime': timestamp.toIso8601String(),
            'products': cartProducts
                .map((e) => {
                      'id': e.id,
                      'title': e.title,
                      'quantity': e.quantity,
                      'price': e.price
                    })
                .toList(),
          }));

      if (response.statusCode >= 400) {
        _orders.insert(
            0,
            OrderItem(
                id: DateTime.now().toString(),
                amount: total,
                dateTime: timestamp,
                products: cartProducts));
        notifyListeners();
      }
    } catch (error) {}
  }
}
