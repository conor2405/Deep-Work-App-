import 'package:deep_work/bloc/liveUsers/live_users_bloc.dart';
import 'package:deep_work/models/live_users.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

class WorldMap extends StatefulWidget {
  final LiveUsersBloc? liveUsersBloc;

  WorldMap({super.key, this.liveUsersBloc});

  @override
  _WorldMapState createState() => _WorldMapState();
}

Future<String> getPath() async {
  final cacheDirectory = await getTemporaryDirectory();
  return cacheDirectory.path;
}

class _WorldMapState extends State<WorldMap> {
  String? path;

  @override
  void initState() {
    super.initState();
    getPath().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        path = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = widget.liveUsersBloc;
    if (path == null) {
      return Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }

    if (bloc != null) {
      return BlocProvider.value(
        value: bloc,
        child: _buildMap(context),
      );
    }

    return BlocProvider<LiveUsersBloc>(
      create: (context) => LiveUsersBloc()..add(LiveUsersInit()),
      lazy: false,
      child: _buildMap(context),
    );
  }

  Widget _buildMap(BuildContext context) {
    return BlocBuilder<LiveUsersBloc, LiveUsersState>(
      builder: (context, state) {
        if (state is LiveUsersInitial) {
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        } else if (state is LiveUsersLoaded) {
            return Stack(children: [
              Container(
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
                        tileProvider: CachedTileProvider(
                          // maxStale keeps the tile cached for the given Duration and
                          // tries to revalidate the next time it gets requested
                          maxStale: const Duration(days: 1000),
                          store: HiveCacheStore(
                            path!,
                            hiveBoxName: 'HiveCacheStore',
                          ),
                        ),
                      ),
                      MarkerLayer(markers: [
                        Marker(
                            point:
                                LatLng(53.280687520332016, -6.326202939104593),
                            child: Icon(Icons.circle,
                                color: Colors.blue[50], size: 2)),
                        ...getMarkers(state.liveUsers)
                      ])
                    ],
                  )),
              Container(
                padding: EdgeInsets.all(30),
                alignment: Alignment.bottomCenter,
                child: Text('Live Users: ${state.liveUsers.users.length}',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              )
            ]);
          } else {
            return Container(
              alignment: Alignment.center,
              child: Text('Error'),
            );
          }
      },
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
