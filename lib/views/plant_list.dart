import 'package:flutter/material.dart';
import 'package:garden/components/plant_item.dart';
import 'package:garden/provider/plants_provider.dart';
import 'package:provider/provider.dart';

class PlantList extends StatelessWidget {
  const PlantList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Plants _plantList = Provider.of(context);
    return Scaffold(
      // ignore: unnecessary_null_comparison
      body: (_plantList.getItems().isEmpty == true)
          ? Stack(
              children: <Widget>[
                ListView(),
                Align(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/gardening.png'),
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: _plantList.count,
              itemBuilder: (context, index) => PlantItem(
                _plantList.byIndex(index),
              ),
            ),
    );
  }
}
