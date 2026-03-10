import 'package:flutter/material.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/settings/setting_page_interface.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/setting_list_view.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({
    super.key,
    required this.node,
    required this.isEnabled,
    required this.onRequestPageUpdate,
    required this.onRequestPageMove,
    required this.onRequestGoBack,
  });

  final PageNode? node;
  final bool isEnabled;
  final Function(int)? onRequestPageUpdate;
  final Function(int)? onRequestPageMove;
  final Function(int)? onRequestGoBack;

  @override
  State<SettingPage> createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage>
    with AutomaticKeepAliveClientMixin
    implements SettingPageInterface {
  GlobalKey<SettingListViewState> _listKey = GlobalKey<SettingListViewState>();

  double _opacity = 0;

  @override
  bool get wantKeepAlive => widget.isEnabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _opacity = widget.isEnabled ? 1.0 : 0.7;
        });
      }
    });
    if (widget.isEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          initFocus();
        }
      });
    }
  }

  @override
  void setFocus(int value) {
    // _listKey.currentState?.initFocus();
  }

  void initFocus() {
    _listKey.currentState?.initFocus();
  }

  @override
  void hidePage() {
    setState(() {
      _opacity = 0;
    });
  }

  @override
  void didUpdateWidget(covariant SettingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled) {
      initFocus();
    }
    setState(() {
      _opacity = widget.isEnabled ? 1.0 : 0.7;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.node == null) {
      return Container(color: Theme.of(context).colorScheme.onTertiary);
    }

    if (widget.node!.builder != null) {
      var page = widget.node!.builder?.call(
        context,
        widget.node!,
        widget.isEnabled,
        (selected) {
          widget.onRequestPageUpdate?.call(selected);
        },
        (selected) {
          widget.onRequestPageMove?.call(selected);
        },
        (index) {
          widget.onRequestGoBack?.call(index);
        },
      );

      return AbsorbPointer(
        absorbing: !widget.isEnabled,
        child: Container(
          color:
              widget.isEnabled
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.onTertiary,
          child: AnimatedOpacity(
            duration: $style.times.fast,
            opacity: _opacity,
            curve: Curves.easeInOut,
            child: page,
          ),
        ),
      );
    }

    double titleFontSize = 35;

    return AbsorbPointer(
      absorbing: !widget.isEnabled,
      child: Container(
        color:
            widget.isEnabled
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.onTertiary,
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: $style.times.med,
          curve: Curves.easeInOut,
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //title
              SizedBox(
                width: widget.isEnabled ? 600 : 400,
                child: AnimatedPadding(
                  duration: $style.times.med,
                  padding: // title up/left padding
                      widget.isEnabled
                          ? EdgeInsets.fromLTRB(120, 60, 40, 0)
                          : EdgeInsets.fromLTRB(80, 60, 80, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      getLocalizedTextByKey(context, widget.node?.title ?? ''),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: 2,
                      style: TextStyle(fontSize: titleFontSize),
                    ),
                  ),
                ),
              ),
              //list
              if (!widget.node!.children.isEmpty)
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: AnimatedPadding(
                      duration: $style.times.med,
                      padding: // item left/right padding
                          widget.isEnabled
                              ? const EdgeInsets.symmetric(
                                horizontal: 80,
                                vertical: 10,
                              )
                              : const EdgeInsets.symmetric(horizontal: 40),
                      child: SettingListView(
                        key: _listKey,
                        node: widget.node!,
                        onItemFocused: (focused) {
                          widget.onRequestPageUpdate?.call(focused);
                        },
                        onItemSelected: (selected) {
                          widget.onRequestPageMove?.call(selected);
                        },
                        onItemTapped: (selected) {
                          // widget.onRequestPageUpdate?.call(selected);
                          widget.onRequestPageMove?.call(selected);
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
