import 'package:mini_projeto_5/models/place.dart';
import 'package:mini_projeto_5/screens/map_screen.dart';
import 'package:mini_projeto_5/utils/location_util.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationInput extends StatefulWidget {
  void Function(PlaceLocation) onSubmit;

  LocationInput(this.onSubmit);

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;

  Future<void> _getCurrentUserLocation() async {
    final locData =
        await Location().getLocation(); //pega localização do usuário

    //CARREGANDO NO MAPA

    final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: locData.latitude, longitude: locData.longitude);

    String address =
        await LocationUtil.getAddress(locData.latitude!, locData.longitude!);
    print('Endereço encontrado');
    final _placeLocation = new PlaceLocation(
        latitude: locData.latitude!,
        longitude: locData.longitude!,
        address: address);

    setState(() {
      print(staticMapImageUrl);
      _previewImageUrl = staticMapImageUrl;
    });

    widget.onSubmit(_placeLocation);
  }

  Future<void> _selectOnMap() async {
    final LatLng selectedPosition = await Navigator.of(context).push(
      MaterialPageRoute(
          fullscreenDialog: true, builder: ((context) => MapScreen())),
    );

    if (selectedPosition == null) return;

    print(selectedPosition.latitude);
    print(selectedPosition.longitude);

    final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: selectedPosition.latitude,
        longitude: selectedPosition.longitude);

    String address = await LocationUtil.getAddress(
        selectedPosition.latitude, selectedPosition.longitude);
    final _placeLocation = new PlaceLocation(
        latitude: selectedPosition.latitude,
        longitude: selectedPosition.longitude,
        address: address);

    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
    print('Chamando o set de local');
    widget.onSubmit(_placeLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: _previewImageUrl == null
              ? Text('Localização não informada!')
              : Image.network(
                  _previewImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Icon(Icons.location_on),
              label: Text('Localização atual'),
              onPressed: _getCurrentUserLocation,
            ),
            TextButton.icon(
              icon: Icon(Icons.map),
              label: Text('Selecione no Mapa'),
              onPressed: _selectOnMap,
            ),
          ],
        )
      ],
    );
  }
}
