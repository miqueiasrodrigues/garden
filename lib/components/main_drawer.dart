import 'package:flutter/material.dart';
import 'package:garden/provider/users_provider.dart';
import 'package:garden/routes/app_route.dart';
import 'package:garden/views/home.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  Widget _createItem(IconData icon, String label, Function() onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Users _users = Provider.of(context);
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(_users.byIndex(0).name),
            accountEmail: Text(_users.byIndex(0).email.toLowerCase()),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(_users.byIndex(0).imageUrl),
              radius: 50.0,
              backgroundColor: Colors.white60,
            ),
          ),
          _createItem(
            Icons.person_outline_sharp,
            'Minha Conta',
            () {
              Navigator.pushNamed(context, AppRoute.routeProfile);
            },
          ),
          _createItem(
            Icons.logout_outlined,
            'Sair',
            () {
              Future.delayed(const Duration(milliseconds: 250), () {
                try {
                  timer.cancel();
                } catch (e) {
                  print(e);
                }
                Navigator.pushReplacementNamed(context, AppRoute.routeLogin);
              });
            },
          ),
        ],
      ),
    );
  }
}
