import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavourite = false});

  static const baseUrl = 'https://shopping-demo-cd112.firebaseio.com/userFavourites';

  void _setFavouriteValue(bool newValue) {
    isFavourite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavouriteStatus(String token, String userId) async {
    final url = '$baseUrl/$userId/$id.json?auth=$token';
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;

    notifyListeners();
    try {
      var response = await http.put(
        url,
        body: json.encode(isFavourite),
      );

      if (response.statusCode >= 400) _setFavouriteValue(oldStatus);
    } catch (error) {
      _setFavouriteValue(oldStatus);
    }
  }
}
