import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:garden/provider/plants_provider.dart';
import 'package:garden/provider/users_provider.dart';
import 'package:garden/routes/app_route.dart';
import 'package:garden/views/create_account.dart';
import 'package:garden/views/dashboard.dart';
import 'package:garden/views/home.dart';
import 'package:garden/views/login.dart';
import 'package:garden/views/plant_form.dart';
import 'package:garden/views/plant_form_edit.dart';
import 'package:garden/views/plant_info.dart';
import 'package:garden/views/plant_register.dart';
import 'package:garden/views/profile.dart';
import 'package:garden/views/profile_edit.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.green,
    ));

    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => Users(),
              ),
              ChangeNotifierProvider(
                create: (context) => Plants(),
              ),
            ],
            child: MaterialApp(
                theme: ThemeData(
                  primarySwatch: Colors.green,
                ),
                initialRoute: AppRoute.routeLogin,
                debugShowCheckedModeBanner: false,
                routes: {
                  AppRoute.routeHome: (context) => const Home(),
                  AppRoute.routeLogin: (context) => const Login(),
                  AppRoute.routeCreateAccount: (context) =>
                      const CreateAccount(),
                  AppRoute.routePlantForm: (context) => const PlantForm(),
                  AppRoute.routePlantInfo: (context) => const PlantInfo(),
                  AppRoute.routePlantFormEdit: (context) =>
                      const PlantFormEdit(),
                  AppRoute.routePlantRegister: (context) =>
                      const PlantRegister(),
                  AppRoute.routeDashboard: (context) => const Dashboard(),
                  AppRoute.routeProfile: (context) => const Profile(),
                  AppRoute.routeProfileEdit: (context) => const ProfileEdit(),
                }),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
