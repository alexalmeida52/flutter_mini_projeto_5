import 'dart:io';

import 'package:mini_projeto_5/provider/great_places.dart';
import 'package:mini_projeto_5/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlacesListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Lugares'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.PLACE_FORM);
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<GreatPlaces>(context, listen: false).fetchPlaces(),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : Consumer<GreatPlaces>(
                child: Center(
                  child: Text('Nenhum local'),
                ),
                builder: (context, greatPlaces, child) =>
                    greatPlaces.itemsCount == 0
                        ? child!
                        : ListView.builder(
                            itemCount: greatPlaces.itemsCount,
                            itemBuilder: (context, index) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: FileImage(
                                    greatPlaces.itemByIndex(index).image),
                              ),
                              title: Text(greatPlaces.itemByIndex(index).title),
                              subtitle: Text(greatPlaces.itemByIndex(index).location!.address != '' ? greatPlaces.itemByIndex(index).location!.address : 'Não informado'),
                              trailing: InkWell(
                                child: Icon(Icons.remove_circle_outlined),
                                onTap: () {
                                  Provider.of<GreatPlaces>(context, listen: false).removePlaceById(greatPlaces.itemByIndex(index).id);
                                },
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed(AppRoutes.PLACE_DETAIL, arguments: greatPlaces.itemByIndex(index));
                              },
                            ),
                          ),
              ),
      ),
    );
  }
}
