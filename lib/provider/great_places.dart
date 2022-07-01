import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:f9_recursos_nativos/models/place.dart';
import 'package:f9_recursos_nativos/utils/db_util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GreatPlaces with ChangeNotifier {
  final _baseUrl = 'https://mobile-cb573-default-rtdb.firebaseio.com';
  List<Place> _items = [];

  Future<void> loadPlaces() async {
    final dataList = await DbUtil.getData('places');
    _items = dataList
        .map(
          (item) => Place(
              id: item['id'],
              title: item['title'],
              image: File(item['image']),
              location: PlaceLocation(
                  latitude: item['lat'],
                  longitude: item['lat'],
                  address: item['address']),
              phone: item['phone']),
        )
        .toList();
    notifyListeners();
  }

  List<Place> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Place itemByIndex(int index) {
    return _items[index];
  }

  Future addPlace(
      String title, File image, PlaceLocation placeLocation, String phone) {
    print('Adicionar');
    final future = http.post(Uri.parse('$_baseUrl/places.json'),
        body: jsonEncode({
          "title": title,
          "lat": placeLocation.latitude,
          "long": placeLocation.longitude,
          "address": placeLocation.address,
          "image": image.path,
          "phone": phone
        }));

    return future.then((response) {
      //print('espera a requisição acontecer');
      print(jsonDecode(response.body));
      final id = jsonDecode(response.body)['name'];

      final newPlace = Place(
          id: id,
          title: title,
          location: placeLocation,
          image: image,
          phone: phone);

      print(response.statusCode);
      _items.add(newPlace);
      DbUtil.insert('places', {
        'id': id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'lat': newPlace.location!.latitude,
        'long': newPlace.location!.longitude,
        'address': newPlace.location!.address,
        'phone': newPlace.phone
      });
      notifyListeners();
    });
  }

  Future<void> fetchPlaces() async {
    final response = await http.get(Uri.parse('$_baseUrl/places.json'));
    if (response.statusCode == 200) {
      List<Place> list = [];
      final map = jsonDecode(response.body);

      map.forEach((k, v) {
        list.add(Place(
          id: k,
          title: v['title'],
          image: v['image'],
          phone: v['phone'],
          location: PlaceLocation(latitude: v['lat'], longitude: v['long'], address: v['address']),
        ));
      });
      _items = list;
      notifyListeners();
    } else {
      throw Exception('Failed to load albums');
    }
  }

}
