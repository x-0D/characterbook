abstract class WindowServiceInterface {
  Future<void> initialize();
  Future<void> minimize();
  Future<void> toggleMaximize();
  Future<void> close();
  Future<bool> isMaximized();
  void addListener(dynamic listener);
  void removeListener(dynamic listener);
}
