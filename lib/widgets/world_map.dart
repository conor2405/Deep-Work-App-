import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class WorldMap extends StatefulWidget {
  @override
  _WorldMapState createState() => _WorldMapState();
}

class _WorldMapState extends State<WorldMap> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: FlutterMap(
          options: MapOptions(
              crs: const Epsg3857(),
              initialCenter: LatLng(27, 10),
              initialZoom: 2.9,
              interactionOptions:
                  InteractionOptions(flags: InteractiveFlag.none),
              backgroundColor: Theme.of(context).colorScheme.background),
          children: [
            TileLayer(
              retinaMode: true,
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_nolabels/{z}/{x}/{y}{r}.png',
              userAgentPackageName: 'com.deep_work.app',
            ),
            MarkerLayer(markers: [
              Marker(
                  point: LatLng(53.280687520332016, -6.326202939104593),
                  child: Icon(Icons.circle, color: Colors.blue[50], size: 2))
            ])
          ],
        ));
  }
}
