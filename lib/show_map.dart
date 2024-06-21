import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ShowMap extends StatefulWidget {
  const ShowMap({super.key});

  @override
  State<ShowMap> createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  late final MapController _mapController;
  final List<Polygon> _polygons = [];
  final List<Marker> _markers = [];
  final List<CircleMarker> _circles = [];
  bool _isEditMode = false;
  String displayZoom = '16';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(52.3738549, 4.8986369),
            initialZoom: 16,
            cameraConstraint: CameraConstraint.contain(
              bounds: LatLngBounds(
                const LatLng(-90, -180),
                const LatLng(90, 180),
              ),
            ),
            onTap: _onMapTab,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            ),
            PolygonLayer(polygons: _polygons),
            CircleLayer(circles: _circles)
          ]),
      // Display infos
      Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white.withOpacity(0.8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('zoom: $displayZoom',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    )),
                Text(
                  'circles: ${_circles.length}',
                ),
                Text('polygons: ${_polygons.length}'),
              ],
            ),
          )),
      // Display edit mode button
      Positioned(
          bottom: 20,
          left: 10,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: _isEditMode ? Colors.red : Colors.grey,
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
            child: const Icon(Icons.edit),
          )),
      //Display zoom buttons and clear button
      Positioned(
          bottom: 20,
          right: 20,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                    shape: const CircleBorder(),
                    onPressed: _zoomIn,
                    child: const Icon(Icons.add)),
                const SizedBox(height: 10),
                FloatingActionButton(
                    shape: const CircleBorder(),
                    onPressed: _zoomOut,
                    child: const Icon(Icons.remove)),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _markers.clear();
                      _polygons.clear();
                      _circles.clear();
                    });
                  },
                  tooltip: 'do something',
                  shape: const CircleBorder(),
                  child: const Icon(Icons.close),
                ),
              ])),
    ]);
  }

  void _onMapTab(TapPosition tapPosition, LatLng latLng) {
    if (_isEditMode) {
      CircleMarker c =
          CircleMarker(point: latLng, color: Colors.red, radius: 10);
      setState(() {
        _circles.add(c);
      });
      if (_circles.length >= 4) {
        _drawPolygon();
      }
    }
  }

  void _drawPolygon() {
    final List<LatLng> points =
        _circles.map((CircleMarker marker) => marker.point).toList();
    setState(() {
      _polygons.clear();
      _polygons.add(Polygon(
          points: points,
          color: Colors.yellow,
          borderColor: Colors.white,
          borderStrokeWidth: 3));
    });
  }

  void _zoomIn() {
    var cPos = _mapController.camera.center;
    var cZoom = _mapController.camera.zoom + 1;
    _mapController.move(cPos, cZoom);
    setState(() {
      displayZoom = cZoom.toStringAsFixed(0);
    });
  }

  void _zoomOut() {
    var cPos = _mapController.camera.center;
    var cZoom = _mapController.camera.zoom - 1;
    _mapController.move(cPos, cZoom);
    setState(() {
      displayZoom = cZoom.toStringAsFixed(0);
    });
  }
}
