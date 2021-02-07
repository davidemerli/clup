import 'dart:async';

import 'package:clup_application/api/authentication.dart';
import 'package:clup_application/api/information_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../gps/gps_component.dart';
import '../configs.dart';

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

  Map _currentStore;
  CameraPosition _currentMapCenter;
  Set<Marker> _markers = Set();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      drawer: CLupDrawer(),
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

              _currentMapCenter = cameraPosition;

              return _buildMap(cameraPosition, lat, lng);
            },
          ),
          if (_currentStore != null) StorePopup(store: _currentStore),
        ],
      ),
    );
  }

  /// Generates the Map Widget
  Widget _buildMap(CameraPosition cameraPosition, lat, lng) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: cameraPosition,
      markers: _markers,
      mapToolbarEnabled: true,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      onTap: (pos) => setState(() => _currentStore = null),
      // if a marker is selected, google maps buttons are moved upwards
      padding: _currentStore != null
          ? const EdgeInsets.only(bottom: 200)
          : const EdgeInsets.all(0),
      onMapCreated: (controller) {
        _controller.complete(controller);
      },
      onCameraMove: (position) => _currentMapCenter = position,
      onCameraIdle: () async {
        var latitude = _currentMapCenter.target.latitude;
        var longitude = _currentMapCenter.target.longitude;

        List stores = await loadNearbyStores(latitude, longitude);

        // Get a list of markers from the list of stores
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

        try {
          // Update markers
          setState(() => _markers = markers);
        } catch (e) {}
      },
    );
  }
}

/// Generates a drawer with the logout button.
/// Should be further extended in production
class CLupDrawer extends StatelessWidget {
  const CLupDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              Navigator.popUntil(context, ModalRoute.withName('/login'));
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}

/// Generates a popup with the selected store information
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

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 200,
          width: constraints.constrainWidth(600),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: clupBlue1,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              _buildDescription(context),
              _buildOpeningText(context),
              _buildGetTicketButton(theme, context)
            ],
          ),
        ),
      );
    });
  }

  Positioned _buildGetTicketButton(TextStyle theme, BuildContext context) {
    return Positioned(
      bottom: 10,
      right: 20,
      left: 20,
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
          Navigator.popAndPushNamed(context, '/map/store');
        },
      ),
    );
  }

  Positioned _buildOpeningText(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: Text(
        "OPEN",
        textAlign: TextAlign.right,
        style: Theme.of(context)
            .textTheme
            .headline4
            .copyWith(color: Colors.greenAccent, fontSize: 24),
      ),
    );
  }

  RichText _buildDescription(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: store['chain_name'] + '\n',
        style: Theme.of(context)
            .textTheme
            .headline4
            .copyWith(color: Colors.white, fontSize: 28),
        children: [
          TextSpan(
            text: store['city'] + '\n',
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: Colors.white, fontSize: 22),
          ),
          TextSpan(
            text: store['address'] + '\n',
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: Colors.white, fontSize: 18),
          )
        ],
      ),
    );
  }
}
