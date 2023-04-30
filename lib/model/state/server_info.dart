import 'package:flutter/foundation.dart';

class ServerInfo with ChangeNotifier, DiagnosticableTreeMixin {
  String? _pw;
  bool _state = false;

  set setPwd(String pwd) {
    _pw = pwd;
  }

  set setState(bool state) {
    _state = state;
    notifyListeners();
  }

  get pw => _pw;

  get state => _state;
}
