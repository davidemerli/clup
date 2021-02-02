import 'package:clip_shadow/clip_shadow.dart';
import 'package:clup_application/api/information_provider.dart';
import 'package:clup_application/api/ticket_handler.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

final clupRed = Color(0xFFF76C5E);
final clupBlue1 = Color(0xFF586BA4);
final clupBlue2 = Color(0xFF1E2848);

class TicketPage extends StatelessWidget {
  final wPerc = 0.85;
  final hPerc = 1.35;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FutureBuilder(
          future: getSelectedStore(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            Map store = snapshot.data;

            return FutureBuilder(
                future: getTicket(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  Map ticket = snapshot.data;

                  if (ticket == null) {
                    return Center(child: Text('Failed to retrieve ticket'));
                  }
                  return Stack(
                    children: [
                      Center(
                        heightFactor: 1.4,
                        child: ClipShadow(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            )
                          ],
                          clipper: TicketClipper(),
                          child: Container(
                            child: _buildTicketContent(context, store, ticket),
                            width: MediaQuery.of(context).size.width * wPerc,
                            height: MediaQuery.of(context).size.width * hPerc,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      CustomQRViewer(wPerc: wPerc, ticket: ticket),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }

  Widget _buildTicketContent(context, store, ticket) {
    return Stack(
      children: [
        _buildTitle(context, store),
        _buildMiddleDecoration(context),
        _buildMapsButton(context),
        _buildValidityDescription(context, store, ticket),
        _buildEstimatedTime(context),
      ],
    );
  }

  Widget _buildEstimatedTime(context) {
    return Positioned(
      top: MediaQuery.of(context).size.width * hPerc * 0.3,
      left: 10,
      child: RichText(
        text: TextSpan(
          text: 'Estimated waiting time: \n',
          style: Theme.of(context).textTheme.bodyText1,
          children: [
            TextSpan(
              text: '40 minutes',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.blue, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidityDescription(context, store, ticket) {
    return Positioned(
      top: MediaQuery.of(context).size.width * hPerc * 0.135,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        width: MediaQuery.of(context).size.width * wPerc,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: 'Queue Position: ',
                style: Theme.of(context).textTheme.headline6,
                children: [
                  TextSpan(
                    text: '45',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: Colors.red, fontSize: 32),
                  ),
                ],
              ),
            ),
            Text('#${ticket["call_number"]}',
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildMapsButton(context) {
    return Container();
    // return Positioned(
    //   top: 0,
    //   right: -2,
    //   child: FlatButton.icon(
    //     label: Icon(Icons.map),
    //     icon: Text(
    //       'Open in Maps',
    //       style: Theme.of(context)
    //           .textTheme
    //           .button
    //           .copyWith(color: clupBlue2, fontWeight: FontWeight.bold),
    //     ),
    //     onPressed: () {},
    //   ),
    // );
  }

  Widget _buildTitle(context, store) {
    return Container(
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * hPerc * 0.17,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            store['store_name'],
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(fontSize: 26, color: Colors.white),
          ),
          Text(
            store['address'],
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: clupBlue1,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          )
        ],
      ),
    );
  }

  Widget _buildMiddleDecoration(context) {
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.width * hPerc * 0.45),
      child: DotWidget(
        totalWidth: MediaQuery.of(context).size.width * wPerc,
      ),
    );
  }
}

class CustomQRViewer extends StatefulWidget {
  const CustomQRViewer({
    Key key,
    @required this.wPerc,
    @required this.ticket,
  }) : super(key: key);

  final double wPerc;
  final Map ticket;

  @override
  _CustomQRViewerState createState() => _CustomQRViewerState();
}

class _CustomQRViewerState extends State<CustomQRViewer> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      curve: Curves.ease,
      color: Colors.white.withAlpha(open ? 255 : 0),
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (open)
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.75),
              child: Opacity(
                opacity: open ? 1 : 0,
                child: Text(
                  'Click anywhere to close',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
                top: open ? 0 : MediaQuery.of(context).size.width * 0.95),
            child: Opacity(
              opacity: !open ? 1 : 0,
              child: Text('Scan the code to enter',
                  style: Theme.of(context).textTheme.headline6),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => open = !open),
              child: AnimatedContainer(
                padding: EdgeInsets.only(
                    top: open ? 0 : MediaQuery.of(context).size.width * 0.5),
                width: MediaQuery.of(context).size.width * (open ? 0.9 : 0.4),
                curve: Curves.ease,
                duration: Duration(milliseconds: 200),
                child: QrImage(
                  data: widget.ticket['ticket_id'].toString(),
                  version: QrVersions.auto,
                  // size: MediaQuery.of(context).size.width * widget.wPerc * 0.5,
                ),
              ),
            ),
          ),
          if (!open)
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                    top: open ? 0 : MediaQuery.of(context).size.width * 0.5),
                child: FlatButton(
                  onPressed: () => setState(() => open = !open),
                  padding: EdgeInsets.symmetric(horizontal: -10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: clupRed.withAlpha(220),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      ' Click to enlarge ',
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
                top: open ? 0 : MediaQuery.of(context).size.width * 1.47),
            child: Opacity(
              opacity: !open ? 1 : 0,
              child: Text(
                  widget.ticket['ticket_id'].toString().padLeft(10, '0'),
                  style: Theme.of(context).textTheme.headline5),
            ),
          ),
        ],
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  final cutPerc = 0.45;

  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * cutPerc - 20)
      ..lineTo(size.width - 20, size.height * cutPerc)
      ..lineTo(size.width, size.height * cutPerc + 20)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height * cutPerc + 20)
      ..lineTo(20, size.height * cutPerc)
      ..lineTo(0, size.height * cutPerc - 20);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 9, dashSpace = 5, startX = 0;
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DotWidget extends StatelessWidget {
  final double totalWidth, dashWidth, emptyWidth, dashHeight;

  final Color dashColor;

  const DotWidget({
    this.totalWidth = 300,
    this.dashWidth = 10,
    this.emptyWidth = 5,
    this.dashHeight = 2,
    this.dashColor = Colors.black,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalWidth ~/ (dashWidth + emptyWidth),
        (_) => Container(
          width: dashWidth,
          height: dashHeight,
          color: dashColor,
          margin: EdgeInsets.only(left: emptyWidth / 2, right: emptyWidth / 2),
        ),
      ),
    );
  }
}
