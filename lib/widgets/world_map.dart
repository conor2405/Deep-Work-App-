import 'package:deep_work/bloc/liveUsers/live_users_bloc.dart';
import 'package:deep_work/models/live_users.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

class WorldMap extends StatefulWidget {
  final LiveUsersBloc? liveUsersBloc;
  final bool enableTiles;

  WorldMap({super.key, this.liveUsersBloc, this.enableTiles = true});

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
    if (kIsWeb) {
      path = '';
      return;
    }
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
    final useCache =
        shouldUseCachedTiles(enableTiles: widget.enableTiles, isWeb: kIsWeb);
    if (useCache && path == null) {
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
    final useCache =
        shouldUseCachedTiles(enableTiles: widget.enableTiles, isWeb: kIsWeb);
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
                      if (widget.enableTiles)
                        TileLayer(
                          retinaMode: true,
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/dark_nolabels/{z}/{x}/{y}{r}.png',
                          userAgentPackageName: 'com.deep_work.app',
                          tileProvider: useCache
                              ? CachedTileProvider(
                                  // maxStale keeps the tile cached for the given Duration and
                                  // tries to revalidate the next time it gets requested
                                  maxStale: const Duration(days: 1000),
                                  store: HiveCacheStore(
                                    path!,
                                    hiveBoxName: 'HiveCacheStore',
                                  ),
                                )
                              : null,
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
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  minimum: const EdgeInsets.only(bottom: 22),
                  child: _CommunityPulse(
                    count: state.liveUsers.users.length,
                  ),
                ),
              ),
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

class _CommunityPulse extends StatefulWidget {
  final int count;

  const _CommunityPulse({required this.count});

  @override
  State<_CommunityPulse> createState() => _CommunityPulseState();
}

class _CommunityPulseState extends State<_CommunityPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _pulseScale = Tween<double>(begin: 0.7, end: 1.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _pulseFade = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = scheme.onSurface.withOpacity(0.86);
    final subTextColor = scheme.onSurface.withOpacity(0.62);
    final accent = scheme.primary.withOpacity(0.9);
    final count = widget.count;
    final label = count == 1 ? 'mind' : 'minds';

    return Container(
      key: const Key('focus_pulse_badge'),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.onSurface.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final size = 18 * _pulseScale.value;
                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(_pulseFade.value),
                      ),
                    );
                  },
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus Pulse',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$count',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' $label in session',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@visibleForTesting
bool shouldUseCachedTiles({required bool enableTiles, required bool isWeb}) {
  return enableTiles && !isWeb;
}

List<Marker> getMarkers(LiveUsers liveUsers) {
  List<LiveUser> liveUsersList = liveUsers.users;
  return liveUsersList
      .map((liveUser) => Marker(
          point: LatLng(liveUser.lat, liveUser.lng),
          child: Icon(Icons.circle, color: Colors.blue[50], size: 2)))
      .toList();
}
