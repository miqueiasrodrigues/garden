import 'package:flutter/material.dart';
import 'package:garden/components/plant_item_status.dart';
import 'package:garden/provider/plants_provider.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Plants _plantList = Provider.of(context);
    return Scaffold(
      // ignore: unnecessary_null_comparison
      body: (_plantList.getActive().isEmpty == true)
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
              itemCount: _plantList.activeCount,
              itemBuilder: (context, index) => PlantItemStatus(
                _plantList.activeByIndex(index),
              ),
            ),
    );
  }
}
