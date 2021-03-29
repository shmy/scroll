part of './scroll.dart';

enum ScrollRefreshIndicatorMode {
  idle,
  drag,
  armed,
  refreshing,
  done,
  hiding,
  error,
}
enum ScrollLoadIndicatorMode {
  idle,
  loading,
  done,
  error,
}

class ScrollRefreshIndicatorStatus {
  final ScrollRefreshIndicatorMode mode;

  bool get idle => mode == ScrollRefreshIndicatorMode.idle;

  bool get drag => mode == ScrollRefreshIndicatorMode.drag;

  bool get armed => mode == ScrollRefreshIndicatorMode.armed;

  bool get refreshing => mode == ScrollRefreshIndicatorMode.refreshing;

  bool get done => mode == ScrollRefreshIndicatorMode.done;

  bool get hiding => mode == ScrollRefreshIndicatorMode.hiding;

  bool get error => mode == ScrollRefreshIndicatorMode.error;

  const ScrollRefreshIndicatorStatus(
      {this.mode = ScrollRefreshIndicatorMode.idle});

  @override
  String toString() {
    return 'RefreshIndicatorValue{refreshIndicatorMode: $mode}';
  }
}

class ScrollLoadIndicatorStatus {
  final ScrollLoadIndicatorMode mode;

  bool get idle => mode == ScrollLoadIndicatorMode.idle;

  bool get loading => mode == ScrollLoadIndicatorMode.loading;

  bool get done => mode == ScrollLoadIndicatorMode.done;

  bool get error => mode == ScrollLoadIndicatorMode.error;

  const ScrollLoadIndicatorStatus({this.mode = ScrollLoadIndicatorMode.idle});

  @override
  String toString() {
    return 'LoadIndicatorValue{mode: $mode}';
  }
}

class ScrollValue {
  ScrollRefreshIndicatorStatus refreshIndicatorStatus;
  ScrollLoadIndicatorStatus loadIndicatorStatus;
  bool refreshEnabled;
  bool loadEnabled;
  bool isEmpty;
  bool isNoMore;

  ScrollValue(
      {this.refreshIndicatorStatus = const ScrollRefreshIndicatorStatus(),
      this.loadIndicatorStatus = const ScrollLoadIndicatorStatus(),
      this.refreshEnabled = true,
      this.loadEnabled = true,
      this.isEmpty = false,
      this.isNoMore = false});

  ScrollValue copyWith(
          {ScrollRefreshIndicatorStatus? refreshIndicatorStatus,
          ScrollLoadIndicatorStatus? loadIndicatorStatus,
          bool? refreshEnabled,
          bool? loadEnabled,
          bool? isEmpty,
          bool? isNoMore}) =>
      ScrollValue(
          refreshIndicatorStatus:
              refreshIndicatorStatus ?? this.refreshIndicatorStatus,
          loadIndicatorStatus: loadIndicatorStatus ?? this.loadIndicatorStatus,
          refreshEnabled: refreshEnabled ?? this.refreshEnabled,
          loadEnabled: loadEnabled ?? this.loadEnabled,
          isEmpty: isEmpty ?? this.isEmpty,
          isNoMore: isNoMore ?? this.isNoMore);

  @override
  String toString() {
    return 'ScrollValue{refreshIndicatorState: $refreshIndicatorStatus, loadIndicatorState: $loadIndicatorStatus, refreshEnabled: $refreshEnabled, loadEnabled: $loadEnabled, isEmpty: $isEmpty, isNoMore: $isNoMore}';
  }
}

class IScrollController extends ValueNotifier<ScrollValue> {
  IScrollController() : super(ScrollValue());
  _ScrollState? _instance;
  List<ValueChanged<_ScrollState>> queues = [];

  set instance(_ScrollState instance) {
    _instance = instance;
    _execQueues();
  }

  disableRefresh() => value = value.copyWith(refreshEnabled: false);

  enableRefresh() => value = value.copyWith(refreshEnabled: true);

  disableLoad() => value = value.copyWith(loadEnabled: false);

  enableLoad() => value = value.copyWith(loadEnabled: true);

  setIsEmpty() => value = value.copyWith(isEmpty: true);

  setIsNoMore() => value = value.copyWith(isNoMore: true);

  resetState() => value = ScrollValue();

  requestRefresh() {
    queues.add((_ScrollState instance) async => await instance._onRefresh());
    _execQueues();
  }

  requestLoadMore() {
    queues.add((_ScrollState instance) async => await instance._onLoad());
    _execQueues();
  }

  _execQueues() {
    if (_instance == null) {
      return;
    }
    queues.forEach((element) {
      element(_instance!);
    });
    queues.clear();
  }

  _setRefreshIdle() => value = value.copyWith(
      refreshIndicatorStatus:
          ScrollRefreshIndicatorStatus(mode: ScrollRefreshIndicatorMode.idle));

  _setRefreshDrag() => value = value.copyWith(
      refreshIndicatorStatus:
          ScrollRefreshIndicatorStatus(mode: ScrollRefreshIndicatorMode.drag));

  _setRefreshArmed() => value = value.copyWith(
      refreshIndicatorStatus:
          ScrollRefreshIndicatorStatus(mode: ScrollRefreshIndicatorMode.armed));

  _setRefreshRefreshing() => value = value.copyWith(
      refreshIndicatorStatus: ScrollRefreshIndicatorStatus(
          mode: ScrollRefreshIndicatorMode.refreshing));

  _setRefreshDone() => value = value.copyWith(
      refreshIndicatorStatus:
          ScrollRefreshIndicatorStatus(mode: ScrollRefreshIndicatorMode.done));

  _setRefreshHiding() => value = value.copyWith(
      refreshIndicatorStatus: ScrollRefreshIndicatorStatus(
          mode: ScrollRefreshIndicatorMode.hiding));

  _setRefreshError() => value = value.copyWith(
      refreshIndicatorStatus:
          ScrollRefreshIndicatorStatus(mode: ScrollRefreshIndicatorMode.error));

  _setLoadIdle() => value = value.copyWith(
      loadIndicatorStatus:
          ScrollLoadIndicatorStatus(mode: ScrollLoadIndicatorMode.idle));

  _setLoadLoading() => value = value.copyWith(
      loadIndicatorStatus:
          ScrollLoadIndicatorStatus(mode: ScrollLoadIndicatorMode.loading));

  _setLoadDone() => value = value.copyWith(
      loadIndicatorStatus:
          ScrollLoadIndicatorStatus(mode: ScrollLoadIndicatorMode.done));

  _setLoadError() => value = value.copyWith(
      loadIndicatorStatus:
          ScrollLoadIndicatorStatus(mode: ScrollLoadIndicatorMode.error));
}
