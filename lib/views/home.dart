import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:garden/components/main_drawer.dart';
import 'package:garden/provider/plants_provider.dart';
import 'package:garden/provider/users_provider.dart';
import 'package:garden/routes/app_route.dart';
import 'package:garden/views/dashboard.dart';
import 'package:garden/views/plant_list.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

late Timer timer;

class _HomeState extends State<Home> {
  Future<void> _refreshPlants(BuildContext context, String userId) {
    return Provider.of<Plants>(context, listen: false).load(userId);
  }

  int _currentTab = 0;
  String _textPage = 'Garden';

  final PageStorageBucket bucket = PageStorageBucket();
  bool _isLoading = true;

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  void initState() {
    super.initState();

    FlutterDownloader.registerCallback(downloadCallback);
    try {
      timer.cancel();
    } catch (e) {
      print(e);
    }

    try {
      final Users _users = Provider.of(context, listen: false);
      timer = Timer.periodic(
        const Duration(seconds: 4),
        (Timer t) => setState(() {
          print('Update');
          _refreshPlants(context, _users.byIndex(0).email.replaceAll('.', ':'));
        }),
      );
      Provider.of<Plants>(context, listen: false)
          .load(_users.byIndex(0).email.replaceAll('.', ':'))
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    } catch (e) {
      print('erro');
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  final PageController controller = PageController(initialPage: 0);

  Widget _currentPage = const PlantList();
  @override
  Widget build(BuildContext context) {
    final Users _users = Provider.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(_textPage),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : DoubleBackToCloseApp(
                snackBar: const SnackBar(
                  elevation: 2,
                  behavior: SnackBarBehavior.floating,
                  width: 250,
                  duration: Duration(milliseconds: 2000),
                  content: Text('Toque novamente para sair',
                      textAlign: TextAlign.center),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
                child: RefreshIndicator(
                  onRefresh: () => _refreshPlants(
                      context, _users.byIndex(0).email.replaceAll('.', ':')),
                  child: PageStorage(
                    bucket: bucket,
                    child: _currentPage,
                  ),
                ),
              ),
        drawer: const MainDrawer(),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  splashRadius: 60,
                  icon: Icon(
                    Icons.home_outlined,
                    color: _currentTab == 0 ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      try {
                        timer.cancel();
                      } catch (e) {
                        print(e);
                      }
                      _currentPage = const PlantList();
                      _currentTab = 0;
                      _textPage = 'Cactus';
                      timer = Timer.periodic(
                        const Duration(seconds: 8),
                        (Timer t) => setState(() {
                          print('Update');
                          _refreshPlants(context,
                              _users.byIndex(0).email.replaceAll('.', ':'));
                        }),
                      );
                    });
                  },
                ),
                const SizedBox(width: 50.0),
                IconButton(
                  splashRadius: 60,
                  icon: Icon(
                    Icons.dashboard_outlined,
                    color: _currentTab == 1 ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentPage = const Dashboard();
                      _currentTab = 1;
                      _textPage = 'Dashboard';
                      try {
                        timer.cancel();
                      } catch (e) {
                        print(e);
                      }

                      timer = Timer.periodic(
                        const Duration(seconds: 2),
                        (Timer t) => setState(() {
                          print('Update');
                          _refreshPlants(context,
                              _users.byIndex(0).email.replaceAll('.', ':'));
                        }),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).pushNamed(
              AppRoute.routePlantForm,
            );
            setState(() {
              _currentPage = const PlantList();
              _currentTab = 0;
              _textPage = 'Garden';
            });
          },
          child: const Icon(Icons.add_outlined),
        ));
  }
}
