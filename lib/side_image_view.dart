import 'dart:io';

import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Model/ItemClass.dart';
import 'package:flutter_application_1/sort_view.dart';
import 'package:flutter_application_1/split_views/upper_split.dart';

class SideImageView extends StatefulWidget {
  const SideImageView({Key? key}) : super(key: key);

  @override
  SideImageViewState createState() => SideImageViewState();
}

class SideImageViewState extends State<SideImageView> {
  List<ItemClass> items = [];
  Set colors = {};

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final args = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      setState(() {
        List<ItemClass> its = args['path_list'] as List<ItemClass>;
        items.addAll(its);
      });
    });
  }

  ReorderableListView makeContainer(BuildContext context) {
    UpperSplitViewState? parent = context.findAncestorStateOfType<UpperSplitViewState>();

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
                    setState(() {
                      items.removeAt(index);
                      colors.clear();
                    });
                  }
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                if (RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlLeft)) {
                  setState(() {
                    if(colors.contains(index)) {
                      colors.remove(index);
                    } else {
                      colors.add(index);
                    }
                  });
                } else {
                  setState(() {
                    colors.clear();
                    colors.add(index);
                  });

                  parent!.setState(() {
                    parent.selectedImg = items[index].imagePath;
                  });
                }
              },
              child: Container(
                color: colors.contains(index) ? Colors.blue : Colors.grey,
                padding: const EdgeInsets.all(3),
                child: Image.file(File(items[index].imagePath)),
              )
            )
          ),
        );
      },
      itemCount: items.length,
      onReorder: (int oldIdx, int newIdx) {
        List tmp = colors.toList();
        tmp.sort();

        // 하나의 아이템
        if(!colors.contains(oldIdx) || tmp.length <= 1) {
          setState(() {
            if (oldIdx < newIdx) {
              newIdx -= 1;
            }
            
            final item = items.removeAt(oldIdx);
            items.insert(newIdx, item);
          });
        } else { // 여러 아이템
          setState(() { 
            List<ItemClass> arr = [];
            int idx = 0;
            for(var i in items) {
              if(!colors.contains(idx)) {
                arr.add(i);
              }
              idx++;
            }

            List<ItemClass> it = [];
            for(var i in tmp) {
              it.add(items[i]);
            }

            if(newIdx >= items.length) {
              arr.addAll(it);
            } else {
              final to = items[newIdx];
              if (arr.contains(to)) {
                int toMoveIndex = arr.indexOf(to);
                arr.insertAll(toMoveIndex, it);
              } else {
                while(true) {
                  newIdx--;
                  if(newIdx < 0) {
                    newIdx = 0;
                  }
                  final to = items[newIdx];
                  if(newIdx == 0 || arr.contains(to)) {
                    int toMoveIndex = arr.indexOf(to);
                    arr.insertAll(toMoveIndex + 1, it);
                    break;
                  }
                }
              }
            }

            items.clear();
            items.addAll(arr);
          });
        }

        colors.clear();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) async {
        setState(() {
          for (var i in detail.files) {
            final it = ItemClass(i.path);
            if(!items.contains(it)) {
              items.add(it);
            }
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