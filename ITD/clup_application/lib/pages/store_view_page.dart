import 'package:clup_application/api/information_provider.dart';
import 'package:clup_application/api/ticket_handler.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const clupRed = Color(0xFFF76C5E);
const clupBlue1 = Color(0xFF586BA4);
const clupBlue2 = Color(0xFF1E2848);

class StoreViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store View'),
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.star_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder(
        future: getSelectedStore(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          Map store = snapshot.data;

          return Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: store['store_name'] + '\n',
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(fontSize: 34),
                    children: [
                      TextSpan(
                        text: store['address'] + '\n',
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(fontSize: 24),
                      ),
                      TextSpan(
                        text: 'OPEN' + '\n',
                        style: Theme.of(context)
                            .textTheme
                            .headline4
                            .copyWith(color: Colors.greenAccent, fontSize: 34),
                      )
                    ],
                  ),
                ),
                FlatButton(
                  height: 100,
                  minWidth: double.infinity,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Wrap(
                    children: [
                      Text(
                        'Join the Queue',
                        style: Theme.of(context).textTheme.headline6.copyWith(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 4),
                        child: FaIcon(
                          FontAwesomeIcons.arrowRight,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  color: clupRed,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return VirtualQueueAlert();
                      },
                    );
                  },
                ),
                SizedBox(
                  height: 100,
                ),
                Opacity(
                  opacity: 0.5,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    padding: EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Reserve an Entrance Coming soon!'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class VirtualQueueAlert extends StatelessWidget {
  const VirtualQueueAlert({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Virtual Queue Status"),
      content: SingleChildScrollView(
        child: RichText(
          text: TextSpan(
            text: 'People in queue:\n',
            style: Theme.of(context).textTheme.button,
            children: [
              TextSpan(
                text: '23\n',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              TextSpan(
                text: 'Estimated waiting time:\n',
              ),
              TextSpan(
                text: '35 minutes\n',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              TextSpan(
                text: 'Do you want to join the virtual queue?',
              ),
            ],
          ),
        ),
      ),
      actions: [
        FlatButton(
          child: Text("CANCEL"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(
            "OK",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          onPressed: () async {
            Map store = await getSelectedStore();

            await createTicket(store['store_id']);

            Navigator.pushNamed(context, '/store/ticket');
          },
        )
      ],
    );
  }
}
