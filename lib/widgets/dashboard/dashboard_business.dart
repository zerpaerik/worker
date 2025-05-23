import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:worker/local/database_creator.dart';
import 'package:worker/model/config.dart';
import 'package:worker/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../projects/detail.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets.dart';

class DashboardBusiness extends StatefulWidget {
  @override
  _DashboardBusinessState createState() => _DashboardBusinessState();
}

class _DashboardBusinessState extends State<DashboardBusiness> {
  Map<String, dynamic>? hours;
  Config? config;

  Geolocator? geolocator = Geolocator();

  Position? userLocation;
  Completer<GoogleMapController>? _controller = Completer();
  GoogleMapController? _ccontroller;
  final Map<String, Marker> _markers = {};
  bool view = false;
  String contract_name = '';
  String address = '';
  String customer = '';
  int location_today = 0;
  int clockin_today = 0;
  int yest_today = 0;
  int? absent_today;
  int? absent_yest;
  int assigned = 0;
  bool isData = false;
  bool isActive = true;
  bool isInactive = false;
  bool isFinished = false;
  bool isAll = false;
  List? coordinates = [];
  bool _isMapLoading = true;
  final _markerAnimationDuration = const Duration(milliseconds: 500);

  void _metricsBusiness(estatus) {
    print('consultando');
    Provider.of<Auth>(context, listen: false)
        .fetchMetricsBusiness(estatus)
        .then((value) {

          print('value metrics');
          print(value);
      setState(() {
        hours = value;
        clockin_today = hours!['today_clock_ins'];
        yest_today = hours!['yesterday_clock_ins'];
        absent_today = hours!['today_absents'];
        absent_yest = hours!['yesterday_absents'];
        location_today = hours!['locations_coordinates'].length;
        hours!['coordinates'] = hours!['coordinates'];
        coordinates = hours!['coordinates'];
        isData = true;
        _isMapLoading = false;
      });
      print('resp hour coordinates');
      print(hours);
      if (_ccontroller != null) {
        _updateMarkers();
      }
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _ccontroller = controller;
    });
    
    // Configurar la cámara inicial
    if (coordinates?.isNotEmpty ?? false) {
      final firstLocation = coordinates!.first;
      final cameraPosition = CameraPosition(
        target: LatLng(firstLocation['lat'], firstLocation['lon']),
        zoom: 12,
      );
      
      // Animar la cámara suavemente
      controller.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
        //duration: _markerAnimationDuration,
      );
    }
  }

  void _updateMarkers() {
    if (_ccontroller == null || coordinates == null) return;

    final newMarkers = <Marker>{};
    
    for (final office in coordinates!) {
      final marker = Marker(
        markerId: MarkerId(office['id'].toString()),
        position: LatLng(office['lat'], office['lon']),
        onTap: () {
          setState(() {
            clockin_today = office['clocked_ins'] ?? 0;
            yest_today = 0;
            contract_name = office['contract_name'];
            address = office['address'];
            assigned = office['number_of_workers'];
          });
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
        infoWindow: InfoWindow(
          title: office['contract_name'],
          snippet: office['address'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailProject(
                  project: {
                    'contract_name': office['contract_name'],
                    'customer': office['customer'],
                    'first_address': office['address'],
                    'current_workday_status': office['workday_status'],
                    'id': office['id'],
                  },
                ),
              ),
            );
          },
        ),
      );
      newMarkers.add(marker);
    }

 setState(() {
  _markers.clear();
  _markers.addAll(
    Map.fromEntries(newMarkers.map((marker) => 
      MapEntry(marker.markerId.value, marker)
    ))
  );
});

    // Actualizar la vista del mapa
    if (_ccontroller != null) {
      setState(() {
        _markers.clear();
        _markers.addAll(
          Map.fromEntries(newMarkers.map((marker) => 
            MapEntry(marker.markerId.value, marker)
          ))
        );
      });
}
   
    
  }

  Future<Position> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return Future.error('Error getting location: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation().then((position) {
      setState(() {
        userLocation = position;
      });
    }).catchError((error) {
      print('Error getting location: $error');
    });
    
    _metricsBusiness('active');
    getTodo(1);
  }

  @override
  void dispose() {
    _ccontroller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        if (_isMapLoading) ...[
          Container(
            margin: const EdgeInsets.only(top: 100),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
        if (!_isMapLoading && isData && hours != null) ...[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              onCameraMove: (position) {},
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  userLocation?.latitude ?? 17.4435,
                  userLocation?.longitude ?? 78.3772,
                ),
                zoom: 12,
              ),
              markers: _markers.values.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              compassEnabled: true,
            ),
          ),
          Positioned.fill(
            top: 30,
            child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            alignment: Alignment.topCenter,
                            width: MediaQuery.of(context).size.width * 0.33,
                            child: Container(
                                alignment: Alignment.topCenter,
                                width: MediaQuery.of(context).size.width * 0.30,
                                height:
                                    MediaQuery.of(context).size.height * 0.14,
                                child: Card(
                                  color: Colors.white.withOpacity(0.9),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text(
                                        'Clocked-in',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (clockin_today > yest_today) ...[
                                            const Icon(
                                              Icons.arrow_upward,
                                              color: Colors.green,
                                              size: 20,
                                            )
                                          ],
                                          if (yest_today > clockin_today) ...[
                                            const Column(
                                              children: [
                                                Icon(
                                                  Icons.arrow_downward,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                              ],
                                            )
                                          ],
                                          if (clockin_today == yest_today) ...[
                                            const Icon(
                                              Icons.swap_vert,
                                              color: Colors.blue,
                                              size: 20,
                                            )
                                          ],
                                          Container(
                                              child: Text(
                                            clockin_today.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 30,
                                                color: HexColor('3E3E3E')),
                                          )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Container(
                                          child: Text(
                                        l10n.workers,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ))
                                    ],
                                  ),
                                )))),
                    Expanded(
                        flex: 1,
                        child: Container(
                            alignment: Alignment.topCenter,
                            width: MediaQuery.of(context).size.width * 0.33,
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.30,
                                height:
                                    MediaQuery.of(context).size.height * 0.14,
                                child: Card(
                                  color: Colors.white.withOpacity(0.9),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(l10n.absents,
                                          style: const TextStyle(fontSize: 13)),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (absent_today! > absent_yest!) ...[
                                            const Icon(
                                              Icons.arrow_downward,
                                              color: Colors.red,
                                              size: 20,
                                            )
                                          ],
                                          if (absent_yest! > absent_today!) ...[
                                            const Icon(
                                              Icons.arrow_upward,
                                              color: Colors.green,
                                              size: 20,
                                            )
                                          ],
                                          if (absent_today == absent_yest) ...[
                                            const Icon(
                                              Icons.swap_vert,
                                              color: Colors.blue,
                                              size: 20,
                                            )
                                          ],
                                          Container(
                                              child: Text(
                                            absent_today.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 30,
                                                color: HexColor('3E3E3E')),
                                          ))
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Container(
                                          child: Text(
                                        l10n.workers,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ))
                                    ],
                                  ),
                                )))),
                    Expanded(
                        flex: 1,
                        child: Container(
                            alignment: Alignment.topCenter,
                            width: MediaQuery.of(context).size.width * 0.33,
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.30,
                                height:
                                    MediaQuery.of(context).size.height * 0.14,
                                child: Card(
                                  color: Colors.white.withOpacity(0.9),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(l10n.locations,
                                          style: const TextStyle(fontSize: 13)),
                                      const Divider(),
                                      if (contract_name != '') ...[
                                        Container(
                                          alignment: Alignment.topLeft,
                                          margin: const EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: Text(
                                            contract_name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          margin: const EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: Text(
                                            address,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                      if (contract_name == '') ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                                child: Text(
                                              coordinates != null
                                                  ? coordinates!.length
                                                      .toString()
                                                  : '0',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 30,
                                                  color: HexColor('3E3E3E')),
                                            ))
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                )))),
                  ],
                )),
          ),
        ],
        if (!_isMapLoading && isData && hours != null && coordinates!.isEmpty) ...[
          Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.30,
              ),
              Image.asset(
                'assets/cactivo2.png',
                width: 30,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Text('')
            ],
          ))
        ]
      ],
    );
  }

  getTodo(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = Config.fromJson(data.first);
    setState(() {
      config = todo;
    });
    return todo;
  }
}
