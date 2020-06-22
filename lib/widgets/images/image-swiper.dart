import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:flutter/material.dart';
import 'package:trotter_flutter/utils/index.dart';

class ImageSwiper extends StatelessWidget {
  const ImageSwiper({
    Key key,
    @required this.context,
    @required this.images,
    @required this.color,
  }) : super(key: key);

  final BuildContext context;
  final List images;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 30),
        width: MediaQuery.of(context).size.width,
        height: 250,
        child: ClipPath(
          clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              return Stack(fit: StackFit.expand, children: <Widget>[
                TrotterImage(
                  imageUrl: this.images[index]['sizes']['medium']['url'],
                  loadingWidgetBuilder: (context) => Center(
                      child: RefreshProgressIndicator(
                    backgroundColor: Colors.white,
                  )),
                ),
              ]);
            },
            loop: true,
            indicatorLayout: PageIndicatorLayout.SCALE,
            itemCount: this.images.length,
            //transformer: DeepthPageTransformer(),
            pagination: new SwiperPagination(
              builder: new SwiperCustomPagination(
                  builder: (BuildContext context, SwiperPluginConfig config) {
                return new ConstrainedBox(
                  child: new Align(
                    alignment: Alignment.topCenter,
                    child: new DotSwiperPaginationBuilder(
                            color: Colors.white.withOpacity(.6),
                            activeColor: color,
                            size: 20.0,
                            activeSize: 20.0)
                        .build(context, config),
                  ),
                  constraints: new BoxConstraints.expand(height: 50.0),
                );
              }),
            ),
          ),
        ));
  }
}
