import 'package:flutter/foundation.dart';
import '../data/repositories/waste_rate_repository.dart';
import '../state/waste_rate_state.dart';

class WasteRateViewModel extends ChangeNotifier {
  WasteRateViewModel(this._repository);

  final WasteRateRepository _repository;
  WasteRateState _state = const WasteRateInitial();

  WasteRateState get state => _state;

  void _setState(WasteRateState next) {
    _state = next;
    notifyListeners();
  }

  Future<void> loadActiveWasteRates() async {
    try {
      _setState(const WasteRateLoading());
      final rates = await _repository.getActiveWasteRates();
      _setState(WasteRateLoaded(rates));
    } catch (e) {
      _setState(
        WasteRateError(
          'Failed to load waste rates',
          exception: e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }
}

