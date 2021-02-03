import 'dart:async';

import 'package:clup_application/api/authentication.dart';
import 'package:clup_application/api/information_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../gps/gps_component.dart';

final clupRed = Color(0xFFF76C5E);
final clupBlue1 = Color(0xFF586BA4);
final clupBlue2 = Color(0xFF1E2848);

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  Map _currentStore = null;

  Set<Marker> _markers = Set();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      drawer: _buildDrawer(),
      appBar: AppBar(title: Text('Select a Store')),
      body: Stack(
        children: [
          FutureBuilder(
              future: determinePosition(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var lat = snapshot.data.latitude;
                var lng = snapshot.data.longitude;
                var cameraPosition = CameraPosition(
                  target: LatLng(lat, lng),
                  zoom: 15,
                );

                return GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: cameraPosition,
                  markers: _markers,
                  mapToolbarEnabled: true,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  onTap: (pos) => setState(() => _currentStore = null),
                  padding: _currentStore != null
                      ? const EdgeInsets.only(bottom: 200)
                      : const EdgeInsets.all(0),
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                  },
                  onCameraIdle: () async {
                    List stores = await loadNearbyStores(lat, lng);

                    Set<Marker> markers = {
                      for (var s in stores)
                        Marker(
                          markerId: MarkerId("${s['store_id']}"),
                          position: LatLng(s['latitude'], s['longitude']),
                          infoWindow: InfoWindow(
                            title: s['chain_name'],
                            snippet: s['address'],
                          ),
                          onTap: () => setState(() => _currentStore = s),
                        )
                    };

                    setState(() => _markers = markers);
                  },
                );
              }),
          Positioned(
            top: 10,
            right: 60,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 40,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                cursorColor: clupBlue1,
                decoration: null,
              ),
            ),
          ),
          if (_currentStore != null)
            Positioned(
              bottom: 10,
              right: 10,
              left: 10,
              child: StorePopup(store: _currentStore),
            )
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: EdgeInsets.only(left: 40, right: 70),
            child: Image.asset('assets/clup_logo_nobg.png', scale: 0.5),
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () {
              logout();
              Navigator.popAndPushNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}

class StorePopup extends StatelessWidget {
  const StorePopup({
    Key key,
    this.store,
  }) : super(key: key);

  final Map store;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme.headline6.copyWith(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        );

    return Container(
      height: 200,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          RichText(
            text: TextSpan(
              text: store['store_name'] + '\n',
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: Colors.white, fontSize: 22),
              children: [
                TextSpan(
                  text: store['address'] + '\n',
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(color: Colors.white, fontSize: 18),
                )
              ],
            ),
          ),
          Positioned(
            top: 30,
            right: 4,
            child: Text(
              "OPEN",
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: Colors.greenAccent, fontSize: 24),
            ),
          ),
          Positioned(
            top: -10,
            right: -10,
            child: IconButton(
              icon: Icon(
                Icons.star_outline_rounded,
                size: 34,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: FlatButton(
              height: 50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Get a Ticket!',
                style: theme,
              ),
              color: clupRed,
              onPressed: () {
                selectStore(store);
                Navigator.pushNamed(context, '/store');
              },
            ),
          )
        ],
      ),
    );
  }
}
