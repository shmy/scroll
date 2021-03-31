library scroll;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

part './scroll_controller.dart';

typedef HeaderBuilder = Widget Function(ScrollValue value, double ratio);
typedef FooterBuilder = Widget Function(ScrollValue value);
typedef FutureVoidCall = Future<void> Function();

class Scroll extends StatefulWidget {
  final Widget child;
  final IScrollController controller;
  final HeaderBuilder headerBuilder;
  final FooterBuilder footerBuilder;
  final FutureVoidCall onRefresh;
  final FutureVoidCall onLoad;
  final double offsetToArmed;
  final double thresholdExtent;

  const Scroll(
      {Key? key,
      required this.child,
      required this.headerBuilder,
      required this.footerBuilder,
      required this.onRefresh,
      required this.onLoad,
      required this.controller,
      this.offsetToArmed = 100,
      this.thresholdExtent = 200})
      : super(key: key);

  @override
  _ScrollState createState() => _ScrollState();
}

class _ScrollState extends State<Scroll> with TickerProviderStateMixin {
  AnimationController? hidingAnimationController;
  AnimationController? springBackAnimationController;
  double offset = 0;
  double lastOffset = 0;
  ScrollValue value = ScrollValue();

  ScrollRefreshIndicatorStatus get refreshIndicatorStatus =>
      value.refreshIndicatorStatus;

  ScrollLoadIndicatorStatus get loadingIndicatorStatus =>
      value.loadIndicatorStatus;

  bool get _userCanRefresh =>
      !refreshIndicatorStatus.refreshing &&
      !refreshIndicatorStatus.done &&
      !refreshIndicatorStatus.error &&
      !refreshIndicatorStatus.hiding;

  double get offsetToArmed => widget.offsetToArmed;

  IScrollController get controller => widget.controller;

  @override
  void initState() {
    controller
      ..addListener(() {
        if (mounted) {
          setState(() {
            value = controller.value;
          });
        }
      })
      ..instance = this;
    hidingAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(
            () {
              if (hidingAnimationController?.status ==
                      AnimationStatus.dismissed ||
                  this.offset == 0 ||
                  !mounted) {
                return;
              }
              if (refreshIndicatorStatus.hiding) {
                double offset =
                    (1 - (hidingAnimationController?.value ?? 0)) * offsetToArmed;
                setState(() {
                  this.offset = -offset;
                });
              }
            },
          );

    springBackAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(
            () {
              if (!mounted ||
                  springBackAnimationController?.status ==
                      AnimationStatus.dismissed) {
                return;
              }
              final double offset = offsetToArmed +
                  (lastOffset.abs() - offsetToArmed) *
                      (1 - (springBackAnimationController?.value ?? 0));
              setState(() {
                this.offset = -offset;
              });
            },
          );
    super.initState();
  }

  @override
  void dispose() {
    hidingAnimationController?.dispose();
    springBackAnimationController?.dispose();
    hidingAnimationController = null;
    springBackAnimationController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = widget.child;
    if (body is! SingleChildRenderObjectWidget &&
        body is! SliverMultiBoxAdaptorWidget) {
      body = SliverToBoxAdapter(child: body);
    }
    return Listener(
      onPointerUp: _onPointerUp,
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: _handleNotification,
        child: ClipRect(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: offsetToArmed,
                child: widget.headerBuilder(
                  value,
                  (offset / offsetToArmed).abs(),
                ),
              ),
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, -offset),
                  child: CustomScrollView(
                    physics: AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    slivers: [
                      body,
                      SliverToBoxAdapter(
                        child: widget.footerBuilder(
                          value,
                          // value.isEmpty,
                          // value.isNoMore,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPointerUp(PointerUpEvent event) {
    if (refreshIndicatorStatus.armed && mounted) {
      setState(() {
        this.lastOffset = offset;
      });
      springBackAnimationController?.forward().whenCompleteOrCancel(
          () => springBackAnimationController?.reverse(from: 0));
      _onRefresh();
    }
  }

  void _handleSetRefreshState(double pixels) {
    double offset = pixels < 0 ? pixels : 0;
    double percentage = (offset / offsetToArmed).abs();
    if (_userCanRefresh && mounted) {
      setState(() {
        this.offset = offset;
      });
    }
    if (_userCanRefresh) {
      if (percentage >= 1.0) {
        controller._setRefreshArmed();
      } else {
        controller._setRefreshDrag();
      }
    }
  }

  void _handleScrollUpdateNotification(ScrollUpdateNotification notify) {
    final ScrollMetrics metrics = notify.metrics;
    if (value.refreshEnabled) _handleSetRefreshState(metrics.pixels);
    if (value.loadEnabled) {
      if (metrics.pixels >= metrics.maxScrollExtent - widget.thresholdExtent &&
          !metrics.outOfRange &&
          !metrics.atEdge) {
        _onLoad();
      }
    }
  }

  bool _handleNotification(ScrollNotification scrollNotification) {
    if (scrollNotification is ScrollUpdateNotification) {
      _handleScrollUpdateNotification(scrollNotification);
    }
    return true;
  }

  Future<void> _onLoad() async {
    if (!loadingIndicatorStatus.idle) {
      return;
    }
    controller._setLoadLoading();
    try {
      await widget.onLoad();
      controller._setLoadDone();
      await Future.delayed(Duration(milliseconds: 500));
      controller._setLoadIdle();
    } catch (e) {
      controller._setLoadError();
    }
  }

  Future<void> _onRefresh() async {
    if (refreshIndicatorStatus.refreshing) {
      return;
    }
    controller._setRefreshRefreshing();
    try {
      await widget.onRefresh();
      controller._setRefreshDone();
    } catch (e) {
      controller._setRefreshError();
    }
    await Future.delayed(Duration(milliseconds: 500));
    controller._setRefreshHiding();
    hidingAnimationController?.forward().whenCompleteOrCancel(() {
      controller._setRefreshIdle();
      hidingAnimationController?.reverse(from: 0);
    });
  }
}
