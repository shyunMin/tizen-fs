import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/models/media_data.dart';
import 'package:tizen_fs/widgets/focus_selectable.dart';
import 'package:tizen_fs/widgets/media_card.dart';
import 'package:tizen_fs/widgets/selectable_listview.dart';

class MediaListView<T extends MediaContentInfo> extends StatefulWidget {
  const MediaListView({
    super.key,
    this.title,
    this.itemBuilder,
    required this.items,
    this.onItemFocused,
    this.onItemSelected,
  });

  final String? title;

  final Widget Function(BuildContext, int index, int selectedIndex, T item)?
  itemBuilder;
  final List<T> items;

  final Function(int)? onItemFocused;
  final Function(int)? onItemSelected;

  @override
  State<MediaListView<T>> createState() => MediaListViewState<T>();
}

class MediaListViewState<T extends MediaContentInfo>
    extends State<MediaListView<T>>
    with FocusSelectable<MediaListView<T>> {
  int _selected = 0;

  void initFocus() {
    focusNode.requestFocus();
  }

  void selectTo(int index) {
    listKey.currentState?.selectTo(index);
  }

  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasfocus) {
        if (hasfocus) {
          listKey.currentState?.selectTo(_selected);
        } else {
          _selected = listKey.currentState?.selectedIndex ?? 1;
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title ?? '',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 180,
            child: SelectableListView(
              scrollOffset: 200,
              key: listKey,
              spacing: 15,
              padding: const EdgeInsets.symmetric(vertical: 25),
              alignment: 0.5,
              itemCount: widget.items.length,
              scrollDirection: Axis.horizontal,
              onItemFocused: (focused) {
                widget.onItemFocused?.call(focused);
              },
              onItemSelected: (selected) {
                widget.onItemSelected?.call(selected);
              },
              itemBuilder: (context, index, selectedIndex, key) {
                return Center(
                  child: MediaCard(
                    ratio: MediaCardRatio.wide,
                    key: key,
                    width: 150,
                    imageUrl: widget.items[index].thumbnailPath,
                    title: widget.items[index].name,
                    description: widget.items[index].modifiedTime?.toString(),
                    content: widget.itemBuilder?.call(
                      context,
                      index,
                      selectedIndex,
                      widget.items[index],
                    ),
                    isSelected:
                        Focus.of(context).hasFocus && index == selectedIndex,
                    onRequestSelect: () {
                      //tab from unselected item
                      _selected = index;
                      listKey.currentState?.selectTo(index);
                      focusNode.requestFocus();
                      Future.microtask(() {
                        widget.onItemSelected?.call(index);
                      });
                      // widget.items[index].onAction?.call();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
