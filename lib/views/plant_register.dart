import 'package:flutter/material.dart';
import 'package:garden/components/plant_register.dart';
import 'package:garden/models/plant.dart';
// ignore: unused_import
import 'package:intl/intl.dart';

class PlantRegister extends StatefulWidget {
  const PlantRegister({Key? key}) : super(key: key);
  @override
  _PlantRegisterState createState() => _PlantRegisterState();
}

class _PlantRegisterState extends State<PlantRegister> {
  @override
  Widget build(BuildContext context) {
    final _plant = ModalRoute.of(context)!.settings.arguments as Plant;
    return Scaffold(
      appBar: AppBar(
        title: Text(_plant.title),
      ),
      // ignore: unnecessary_null_comparison
      body: (_plant.register == null)
          ? Stack(
              children: <Widget>[
                ListView(),
                Align(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/monitoring.png'),
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: _plant.register.length,
              itemBuilder: (context, index) => PlantsRegister(
                _plant.register.values.elementAt(index),
                _plant,
              ),
            ),
    );
  }
}
