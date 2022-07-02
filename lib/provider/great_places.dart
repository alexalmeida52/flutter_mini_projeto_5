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

    return future.then((response) async {
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

      final dataList = await DbUtil.selectOldestRecord();
      List<Map<String, dynamic>> result = dataList
          .map((item) => {"id": item['id'], "amount": item['amount']})
          .toList();

      if (result != null && !result.isEmpty) {
        int count = result[0]['amount'];
        print(count);
        String oldestId = result[0]['id'];
        if (count > 5) {
          print('Remover $oldestId');
          DbUtil.deleteById(oldestId);
        } else {
          print('Ainda não existe 5 registros');
        }
      }
      notifyListeners();
    });
  }

  Future<void> fetchPlaces() async {
    print('iniciando o fetch');
    final response = await http
        .get(Uri.parse('$_baseUrl/places.json'))
        .timeout(const Duration(seconds: 2), onTimeout: () {
      // Time has run out, do what you wanted to do.
      return http.Response(
          'Error', 408); // Request Timeout response status code
    });
    print(response);
    if (response.statusCode == 200) {
      print('statusCode ${response.statusCode}');
      List<Place> list = [];
      final map = jsonDecode(response.body);
      // print(map);
      map.forEach((k, v) {
        list.add(Place(
          id: k,
          title: v['title'],
          image: File(v['image']),
          phone: v['phone'],
          location: PlaceLocation(
              latitude: v['lat'], longitude: v['long'], address: v['address']),
        ));
      });
      print('Lista populada');
      _items = list;
      print(_items.length);
      notifyListeners();
    } else {
      print('error');
      await loadPlaces();
    }
  }

  void removePlaceById(String id) async {
    final response =
        await http.delete(Uri.parse('$_baseUrl/places/$id.json'));
    if (response.statusCode == 200) {
      int index = _items.indexWhere((p) => p.id == id);

      if (index >= 0) {
        _items.removeAt(index);
        await DbUtil.deleteById(id);
        notifyListeners();
      }
    }
  }
}
