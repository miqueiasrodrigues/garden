import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:garden/components/snackbar.dart';
import 'package:garden/models/default.dart';
import 'package:garden/models/plant.dart';
import 'package:garden/models/plant_conf.dart';
import 'package:garden/provider/plants_provider.dart';
import 'package:garden/provider/users_provider.dart';
import 'package:garden/routes/app_route.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PlantInfo extends StatefulWidget {
  const PlantInfo({Key? key}) : super(key: key);

  @override
  _PlantInfoState createState() => _PlantInfoState();
}

class _PlantInfoState extends State<PlantInfo> {
  bool _isLoading = false;
  final Snackbar _snackBar = new Snackbar();
  final Default _default = new Default();
  final PlantConf _plantConf = new PlantConf();

  @override
  Widget build(BuildContext context) {
    final Users _users = Provider.of(context);
    final _plant = ModalRoute.of(context)!.settings.arguments as Plant;

    return Scaffold(
      appBar: AppBar(
        title: Text(_plant.title),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Image.network(
                    _plant.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Nome'),
                  leading: const Icon(Icons.book_outlined),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(_plant.title),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Temperatura'),
                  leading: const Icon(Icons.thermostat_outlined),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text('Mín: ${_plant.temperatureMin}°C'),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Máx: ${_plant.temperatureMax}°C'),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Umidade do solo'),
                  leading: const Icon(Icons.cloud_outlined),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          _plantConf.defMoisture(
                              _plant.moistureMin, _plant.moistureMax),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Mín: ${_plant.moistureMin}%'),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Máx: ${_plant.moistureMax}%'),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Iluminação'),
                  leading: const Icon(Icons.wb_sunny_outlined),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          _plantConf.defLighting(
                              _plant.lightingMin, _plant.lightingMax),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Mín: ${_plant.lightingMin}%'),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Máx: ${_plant.lightingMax}%'),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Tempo de luz'),
                  leading: const Icon(Icons.access_time_rounded),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                            'Mín: ${_plantConf.readTimestamp(_plantConf.sunTimeValue(
                                  _plantConf.defLighting(
                                      _plant.lightingMin, _plant.lightingMax),
                                ).first)}'),
                      ),
                      (_plantConf.defLighting(
                                  _plant.lightingMin, _plant.lightingMax) ==
                              'Sol pleno')
                          ? Container()
                          : Expanded(
                              flex: 2,
                              child: Text(
                                  'Máx: ${_plantConf.readTimestamp(_plantConf.sunTimeValue(
                                        _plantConf.defLighting(
                                            _plant.lightingMin,
                                            _plant.lightingMax),
                                      ).last)}'),
                            ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Rede'),
                  leading: const Icon(Icons.wifi_outlined),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(_plant.ssid.toString()),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Situação'),
                  leading: Icon((_plant.situation != true)
                      ? Icons.public_off_outlined
                      : Icons.public_outlined),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          (_plant.situation != true) ? 'Desativada' : 'Ativada',
                          style: TextStyle(
                              color: (_plant.situation != true)
                                  ? Colors.red
                                  : Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
                (_plant.situation == true)
                    ? Column(
                        children: [
                          const Divider(),
                          ListTile(
                            title: const Text('Arduino'),
                            leading: SizedBox(
                              width: 25,
                              height: 25,
                              child: Image.asset(
                                'assets/images/motherboard.png',
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Conectado',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                            trailing: SizedBox(
                              width: 60,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title:
                                              const Text('Desativar arduino?'),
                                          content: const Text(
                                              'Você também vai desativa a cultura,\nTem certeza?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Não'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Sim'),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                            )
                                          ],
                                        ),
                                      ).then((value) async {
                                        if (value) {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          try {
                                            await Provider.of<Plants>(context,
                                                    listen: false)
                                                .put(
                                              Plant(
                                                plantId: _plant.plantId,
                                                title: _plant.title,
                                                imageUrl: _plant.imageUrl,
                                                moistureMin: _plant.moistureMin,
                                                moistureMax: _plant.moistureMax,
                                                moisture: _plant.moisture,
                                                temperatureMin:
                                                    _plant.temperatureMin,
                                                temperatureMax:
                                                    _plant.temperatureMax,
                                                temperature: _plant.temperature,
                                                lightingMin: _plant.lightingMin,
                                                lightingMax: _plant.lightingMax,
                                                lighting: _plant.lighting,
                                                situation: false,
                                                arduino: _plant.arduino,
                                                date: _plant.date,
                                                register: _plant.register,
                                                timer: _plant.timer,
                                                ssid: _plant.ssid,
                                                pass: _plant.pass,
                                              ),
                                              _users
                                                  .byIndex(0)
                                                  .email
                                                  .replaceAll('.', ':'),
                                            );
                                            await Navigator.of(context)
                                                .pushReplacementNamed(
                                                    AppRoute.routeHome);
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          } catch (e) {
                                            _snackBar.snackbarFloat(
                                                e.toString(), context, true);
                                          }
                                        }
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.delete_outlined,
                                      color: Colors.red,
                                    ),
                                    splashRadius: 30,
                                  )
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                        ],
                      )
                    : Column(
                        children: [
                          const Divider(),
                          ListTile(
                            title: const Text('Código do arquivo'),
                            leading: const Icon(Icons.code_outlined),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'xxxx_${_plant.title}_conf.txt'
                                        .toLowerCase(),
                                  ),
                                ),
                              ],
                            ),
                            trailing: SizedBox(
                              width: 60,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final status =
                                          await Permission.storage.request();

                                      if (status.isGranted) {
                                        const String externalDir =
                                            '/storage/emulated/0/Download/Cactus';
                                        try {
                                          await Directory(externalDir).create();
                                        } catch (e) {
                                          print(e);
                                        }

                                        await FlutterDownloader.enqueue(
                                          url: _plant.arduino.toString(),
                                          fileName: (_default.getId() +
                                                  '_${_plant.title}_' +
                                                  'conf.txt')
                                              .toLowerCase(),
                                          savedDir: externalDir,
                                          showNotification: true,
                                          openFileFromNotification: true,
                                        );
                                        _snackBar.snackbar(
                                            'O download do arquivo foi realizado com sucesso!',
                                            context,
                                            false);
                                      } else {
                                        _snackBar.snackbar(
                                            'O download do arquivo não foi realizado!',
                                            context,
                                            true);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.download_outlined,
                                      color: Colors.green,
                                      size: 26,
                                    ),
                                    splashRadius: 30,
                                  )
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                        ],
                      )
              ],
            ),
    );
  }
}
