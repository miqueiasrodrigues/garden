import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:garden/data/dammy_users.dart';
import 'package:garden/models/user.dart';

class Users with ChangeNotifier {
  final Map<String, User> _items = {...DAMMY_USERS};

  User byIndex(int index) {
    return _items.values.elementAt(index);
  }

  Future<void> put(User _user) async {
    _items.clear();
    if (_user == null) {
      return;
    }
    if (_user.email != null &&
        _user.email.trim().isNotEmpty &&
        _items.containsKey(_user.email)) {
      _items.update(
        _user.email,
        (_) => _user,
      );
    } else {
      _items.putIfAbsent(
        _user.email,
        () => User(
          email: _user.email,
          name: _user.name,
          password: _user.password,
          imageUrl: _user.imageUrl,
        ),
      );
    }

    notifyListeners();
  }

  Future<void> deleteImg(User _user) async {
    try {
      await FirebaseStorage.instance.refFromURL(_user.imageUrl).delete();
    } catch (e) {
      print("Error deleting db from cloud: $e");
    }
  }
}
