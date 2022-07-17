import 'package:flutter/material.dart';
import 'package:garden/models/plant.dart';
import 'package:garden/models/plant_conf.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:sticky_headers/sticky_headers/widget.dart';

class PlantsRegister extends StatelessWidget {
  final List<dynamic> _register;
  final Plant _plant;
  // ignore: use_key_in_widget_constructors
  const PlantsRegister(this._register, this._plant);

  bool _isWarning() {
    return ((_register.elementAt(2) > _plant.moistureMax) ||
        (_register.elementAt(2) < _plant.moistureMin) ||
        (_register.elementAt(3) > _plant.temperatureMax) ||
        (_register.elementAt(3) < _plant.temperatureMin) ||
        (_register.elementAt(4) > _plant.lightingMax) ||
        (_register.elementAt(4) < _plant.lightingMin));
  }

  @override
  Widget build(BuildContext context) {
    final PlantConf _plantConf = new PlantConf();
    return StickyHeader(
      header: Container(
        height: 55.0,
        color:
            _isWarning() == true ? Colors.red.shade300 : Colors.green.shade300,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Text(
          '${_register.elementAt(1)}',
        ),
      ),
      content: Column(
        children: [
          ListTile(
            title: const Text('Temperatura'),
            leading: const Icon(Icons.thermostat_outlined),
            subtitle: Text('${_register.elementAt(3)}°'),
          ),
          ListTile(
            title: const Text('Umidade'),
            leading: const Icon(Icons.cloud_outlined),
            subtitle: Text('${_register.elementAt(2)}%'),
          ),
          ListTile(
            title: const Text('Iluminação'),
            leading: const Icon(Icons.wb_sunny_outlined),
            subtitle: Text('${_register.elementAt(4)}%'),
          ),
          ListTile(
            title: const Text('Tempo'),
            leading: const Icon(Icons.access_time_rounded),
            subtitle: Text(
                _plantConf.readTimestamp(_register.elementAt(5)).toString()),
          ),
        ],
      ),
    );
  }
}
