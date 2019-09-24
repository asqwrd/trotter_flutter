import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:url_launcher/url_launcher.dart';

class StaticMap extends StatefulWidget {
  @required
  final String googleMapsApiKey;
  final double width;
  final double height;
  final double lat;
  final double lng;
  final int zoom;
  final Color color;

  StaticMap(this.googleMapsApiKey,
      {this.width, this.height, this.lat, this.lng, this.zoom, this.color});

  @override
  _StaticMapState createState() => new _StaticMapState(
      width: this.width,
      height: this.height,
      lat: this.lat,
      lng: this.lng,
      color: this.color,
      zoom: this.zoom);
}

class _StaticMapState extends State<StaticMap> {
  Uri renderURL;
  double width = 600;
  double height = 400;

  final double lat;
  final double lng;
  final int zoom;
  final Color color;

  _buildUrl() {
    final baseUri = new Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        port: 443,
        path: '/maps/api/staticmap',
        queryParameters: {
          'size': '${width.round()}x${height.round()}',
          'center': '$lat,$lng',
          'markers': '$lat,$lng',
          'zoom': '$zoom',
          'scale': '2',
          'key': '${widget.googleMapsApiKey}'
        });

    setState(() {
      renderURL = baseUri;
    });
  }

  @override
  void initState() {
    _buildUrl();
    super.initState();
  }

  _StaticMapState(
      {this.lat, this.lng, this.width, this.height, this.zoom, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
        //opacity: 1,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Stack(children: <Widget>[
          Positioned.fill(
              child: ClipPath(
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: TransitionToImage(
                    image: AdvancedNetworkImage(
                      this.renderURL.toString(),
                      useDiskCache: true,
                      cacheRule: CacheRule(maxAge: const Duration(days: 1)),
                    ),
                    loadingWidgetBuilder:
                        (BuildContext context, double progress, test) => Center(
                            child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    )),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    placeholder: const Icon(Icons.refresh),
                    enableRefresh: true,
                  ))),
          Positioned(
              right: 15,
              top: 10,
              child: Container(
                  child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                onPressed: () async {
                  final url =
                      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    print('Could not launch $url');
                  }
                },
                color: this.color != null ? this.color : Colors.blue,
                child: AutoSizeText(
                  'View in maps',
                  style: TextStyle(
                      color: this.color != null
                          ? fontContrast(this.color)
                          : Colors.white,
                      fontWeight: FontWeight.w300),
                ),
              )))
        ]));
  }
}
