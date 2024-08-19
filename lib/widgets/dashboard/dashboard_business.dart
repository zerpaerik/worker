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
  //Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(17.4435, 78.3772),
    zoom: 4.0,
  );
  List<MarkerId> listMarkerIds = [];

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

  void _metricsBusiness(estatus) {
    print('consultando');
    Provider.of<Auth>(context, listen: false)
        .fetchMetricsBusiness(estatus)
        .then((value) {
      setState(() {
        hours = value;
        clockin_today = hours!['today_clock_ins'];
        yest_today = hours!['yesterday_clock_ins'];
        absent_today = hours!['today_absents'];
        absent_yest = hours!['yesterday_absents'];
        location_today = hours!['coordinates'].length;
        hours!['coordinates'] = hours!['coordinates'];
        coordinates = hours!['coordinates'];
        isData = true;
      });
      print('resp hour coordinates');
      print(hours);
      _onMapCreated(_ccontroller!);
    });
  }

  Future<void> _onMapCreated(GoogleMapController _ccontroller) async {
    setState(() {
      _markers.clear();
      print('c00rd map created');
      if (coordinates!.isNotEmpty) {
        for (final office in coordinates!) {
          //  print('office coordinates');
          //print(office);
          final marker = Marker(
            markerId: MarkerId(office['id'].toString()),
            position: LatLng(office['lat'], office['lon']),
            onTap: () {
              print('tocando marker');
              print(office);
              setState(() {
                //  location_today = 1;
                clockin_today = office['clocked_ins'] ?? 0;
                yest_today = 0;
                contract_name = office['contract_name'];
                address = office['address'];
                assigned = office['number_of_workers'];
              });
            },
            infoWindow: InfoWindow(
              title: office['contract_name'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailProject(
                            project: {
                              'contract_name': office['contract_name'],
                              'customer': office['customer'],
                              'first_address': office['address'],
                              'current_workday_status':
                                  office['workday_status'],
                              'id': office['id'],
                            },
                          )),
                );
              },
            ),
          );
          _markers[office['contract_name']] = marker;
        }
      } else {
        print('no hay coord que renderizar');
        final marker = Marker(
          markerId: MarkerId('1'),
          position: LatLng(userLocation!.latitude, userLocation!.longitude),
          onTap: () {
            setState(() {});
          },
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: '',
            onTap: () {},
          ),
        );
      }
    });
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
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

  @override
  void initState() {
    _getLocation().then((position) {
      userLocation = position;
    });
    _metricsBusiness('active');
    super.initState();
    getTodo(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: <Widget>[
        if (!isData) ...[
          Container(
            margin: const EdgeInsets.only(top: 100),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
        if (isData && hours != null && coordinates!.isNotEmpty) ...[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onTap: () {},
              child: GoogleMap(
                onCameraMove: (context) {
                  //_metricsBusiness();
                },
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(hours!['coordinates'][0]['lat'] ?? 0,
                      hours!['coordinates'][0]['lon'] ?? 0),
                  zoom: 3.0,
                ),
                markers: _markers.values.toSet(),
              ),
            ),
          ),
          Positioned.fill(
            top: 30,
            //left: 100,
            //right: 100,
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
          /*  Positioned.fill(
            top: 450,
            //left: 100,
            //right: 100,
            child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Card(
                  color: Colors.white.withOpacity(0.9),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Text(
                              'Current week snapshot: - ',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Last Update',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                  alignment: Alignment.topCenter,
                                  width:
                                      MediaQuery.of(context).size.width * 0.33,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                                child: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.green)),
                                            Container(
                                                child: Text(
                                              clockin_today.toString(),
                                              style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 30,
                                                      color:
                                                          HexColor('3E3E3E'))),
                                            )),
                                          ],
                                        ),
                                        Container(
                                            child: Text(
                                          'Workers',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ))
                                      ],
                                    ),
                                  ))),
                          Expanded(
                              flex: 1,
                              child: Container(
                                  alignment: Alignment.topCenter,
                                  width:
                                      MediaQuery.of(context).size.width * 0.33,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                                child: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.green)),
                                            Container(
                                                child: Text(
                                              absent_today.toString(),
                                              style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 30,
                                                      color:
                                                          HexColor('3E3E3E'))),
                                            ))
                                          ],
                                        ),
                                        Container(
                                            child: Text(
                                          'Workers',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ))
                                      ],
                                    ),
                                  ))),
                          Expanded(
                              flex: 1,
                              child: Container(
                                  alignment: Alignment.topCenter,
                                  width:
                                      MediaQuery.of(context).size.width * 0.33,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        if (contract_name != '') ...[
                                          Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(
                                                left: 5, right: 5),
                                            child: Text(
                                              contract_name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(
                                                left: 5, right: 5),
                                            child: Text(
                                              address,
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                        if (contract_name == '') ...[
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                  child: Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.green)),
                                              Container(
                                                  child: Text(
                                                coordinates != null
                                                    ? coordinates.length
                                                        .toString()
                                                    : '0',
                                                style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 30,
                                                        color: HexColor(
                                                            '3E3E3E'))),
                                              ))
                                            ],
                                          ),
                                          Container(
                                              child: Text(
                                            'Locations',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ))
                                        ],
                                      ],
                                    ),
                                  ))),
                        ],
                      )
                    ],
                  ),
                )),
          )*/
        ],
        if (isData && hours != null && coordinates!.isEmpty) ...[
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
              Text(l10n.no_locations)
            ],
          ))
        ]
      ],
    );
  }
}
