import 'package:flutter/foundation.dart';

enum ViewState { idle, busy, error }

class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _state == ViewState.busy;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _state = ViewState.error;
    notifyListeners();
  }

  Future<void> runBusyFuture(Future Function() task) async {
    try {
      setState(ViewState.busy);
      await task();
      setState(ViewState.idle);
    } catch (e) {
      setError(e.toString());
    }
  }
}