import 'package:deep_work/bloc/liveUsers/live_users_bloc.dart';
import 'package:deep_work/models/live_users.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class WorldMap extends StatefulWidget {
  @override
  _WorldMapState createState() => _WorldMapState();
}

class _WorldMapState extends State<WorldMap> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LiveUsersBloc()..add(LiveUsersInit()),
      child: BlocBuilder<LiveUsersBloc, LiveUsersState>(
        builder: (context, state) {
          if (state is LiveUsersInitial) {
            return Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          } else if (state is LiveUsersLoaded) {
            return Container(
                alignment: Alignment.center,
                child: FlutterMap(
                  options: MapOptions(
                      crs: const Epsg3857(),
                      initialCenter: LatLng(27, 10),
                      initialZoom: 2.9,
                      interactionOptions:
                          InteractionOptions(flags: InteractiveFlag.none),
                      backgroundColor:
                          Theme.of(context).colorScheme.background),
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
                          child: Icon(Icons.circle,
                              color: Colors.blue[50], size: 2)),
                      ...getMarkers(state.liveUsers)
                    ])
                  ],
                ));
          } else {
            return Container(
              alignment: Alignment.center,
              child: Text('Error'),
            );
          }
        },
      ),
    );
  }
}

List<Marker> getMarkers(LiveUsers liveUsers) {
  List<LiveUser> liveUsersList = liveUsers.users;
  return liveUsersList
      .map((liveUser) => Marker(
          point: LatLng(liveUser.lat, liveUser.lng),
          child: Icon(Icons.circle, color: Colors.blue[50], size: 2)))
      .toList();
}
