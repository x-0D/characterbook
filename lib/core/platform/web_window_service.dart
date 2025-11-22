import 'window_service_interface.dart';

class WebWindowService implements WindowServiceInterface {
  @override
  Future<void> initialize() async { }

  @override
  Future<void> minimize() async {}

  @override
  Future<void> toggleMaximize() async {}

  @override
  Future<void> close() async {}

  @override
  Future<bool> isMaximized() async => false;

  @override
  void addListener(dynamic listener) {}

  @override
  void removeListener(dynamic listener) {}
}
