import 'package:mini_projeto_5/utils/location_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import '../models/place.dart';

class PlaceDetail extends StatelessWidget {
  const PlaceDetail({Key? key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    final Place _place = ModalRoute.of(context)!.settings.arguments as Place;
    final _previewImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: _place.location!.latitude,
        longitude: _place.location!.longitude);
    return Card(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text('${_place.title}', style: TextStyle(fontSize: 25),),
            SizedBox(height: 20,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.add_location_alt),
                Expanded(child: Text('Endereço: ${_place.location!.address}', style: TextStyle(fontSize: 15),)),
              ],
            ),
            SizedBox(height: 20,),
            ElevatedButton.icon(style: ElevatedButton.styleFrom(primary: Colors.green), icon: Icon(Icons.phone), label: Text(_place.phone), onPressed: () {
              FlutterPhoneDirectCaller.callNumber(_place.phone);
            }),
            SizedBox(height: 20,),
            Container(
              // width: 180,
              // height: 100,;
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey),
              ),
              alignment: Alignment.center,
              child: Image.file(_place.image),
            ),
            Image.network(
              _previewImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
