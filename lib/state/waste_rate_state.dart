import '../data/models/waste_rate_model.dart';

sealed class WasteRateState {
  const WasteRateState();
}

class WasteRateInitial extends WasteRateState {
  const WasteRateInitial();
}

class WasteRateLoading extends WasteRateState {
  const WasteRateLoading();
}

class WasteRateLoaded extends WasteRateState {
  const WasteRateLoaded(this.rates);

  final List<WasteRateModel> rates;
}

class WasteRateError extends WasteRateState {
  const WasteRateError(this.message, {this.exception});

  final String message;
  final Exception? exception;
}

