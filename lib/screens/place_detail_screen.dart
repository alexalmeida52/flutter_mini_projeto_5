import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/place_detail.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes'),),
      body: PlaceDetail()
    );
  }
}