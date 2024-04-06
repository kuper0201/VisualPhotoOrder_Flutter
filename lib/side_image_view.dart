import 'dart:io';

import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter_application_1/Model/ItemClass.dart';
import 'package:flutter_application_1/sort_view.dart';

class SideImageView extends StatefulWidget {
  const SideImageView({Key? key}) : super(key: key);

  @override
  SideImageViewState createState() => SideImageViewState();
}

class SideImageViewState extends State<SideImageView> {
  List items = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final args = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      setState(() {
        items = args['path_list'];
      });
    });
  }

  ReorderableListView makeContainer(BuildContext context) {
    SortViewState? parent = context.findAncestorStateOfType<SortViewState>();

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        return ReorderableDragStartListener(
          key: Key("$index"),
          index: index,
          child: ContextMenuRegion(
            contextMenu: GenericContextMenu(
              buttonConfigs: [
                ContextMenuButtonConfig(
                  "Delete",
                  onPressed: () {
                    items.removeWhere((e) => e.imagePath == items[index].imagePath);
                    setState(() {});
                  }
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                parent!.setState(() {
                  parent.selectedImg = items[index].imagePath;
                });
              }, child: Container(
                padding: const EdgeInsets.all(3),
                child: Image.file(File(items[index].imagePath)),
              )
            )
          ),
        );
      },
      itemCount: items.length,
      onReorder: (int oldIdx, int newIdx) {
        setState(() {
          if (oldIdx < newIdx) {
            newIdx -= 1;
          }
          final item = items.removeAt(oldIdx);
          items.insert(newIdx, item);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) async {
        setState(() {
          for (var i in detail.files) {
            items.add(ItemClass(i.path));
          }
        });
      },
      onDragEntered: (detail) {
        setState(() {
          
        });
      },
      onDragExited: (detail) {
        setState(() {

        });
      },
      child: makeContainer(context),
    );
  }
}