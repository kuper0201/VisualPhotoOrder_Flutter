import 'dart:io';
import 'dart:isolate';

import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/rendering.dart';
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
  Set select = {};

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

  void reorderOneItem(int oldIdx, int newIdx) {
    if (oldIdx < newIdx) {
      newIdx -= 1;
    }

    setState(() {
      final item = items.removeAt(oldIdx);
      items.insert(newIdx, item);
    });
  }

  static void scrollFun(ScrollController sc) async {
    sc.animateTo(sc.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  ReorderableListView makeContainer(BuildContext context) {
    UpperSplitViewState? parent = context.findAncestorStateOfType<UpperSplitViewState>();

    ScrollController sc = ScrollController();

    return ReorderableListView.builder(
      scrollController: sc,
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
                      select.clear();
                    });
                  }
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                if (RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlLeft)) {
                  setState(() {
                    select.contains(index) ? select.remove(index) : select.add(index);
                  });
                } else {
                  setState(() {
                    select.clear();
                    select.add(index);
                  });

                  parent!.setState(() {
                    parent.selectedImg = items[index].imagePath;
                  });
                }
              },
              child: DropTarget(
                onDragDone: (details) {
                  RenderBox rb = items[index].globalKey.currentContext!.findRenderObject() as RenderBox;
                  double half = rb.size.height / 2;

                  int insertIdx = (details.localPosition.dy < half) ? index : index + 1;

                  List<ItemClass> arr = [];
                  for(var i in details.files) {
                    ItemClass it = ItemClass(i.path);
                    if(!items.contains(it)) {
                      arr.add(it);
                    }
                  }

                  setState(() {
                    items.insertAll(insertIdx, arr);
                  });
                },
                onDragUpdated: (details) {
                  RenderSliverList rb = context.findRenderObject() as RenderSliverList;
                  double scUp = rb.getAbsoluteSize().height * (1 / 4);
                  double scDown = rb.getAbsoluteSize().height * (3 / 4);

                  double dp = details.globalPosition.dy;
                  double scroll = 0.0;
                  if(dp < scUp) {
                    scroll = sc.offset - 1000;
                    if(sc.offset > sc.position.minScrollExtent) {
                      sc.animateTo(scroll, duration: Duration(milliseconds: 2000), curve: Curves.ease);
                    }
                  } else if(dp > scDown) {
                    scroll = sc.offset + 1000;
                    if(sc.offset < sc.position.maxScrollExtent) {
                      sc.animateTo(scroll, duration: Duration(milliseconds: 2000), curve: Curves.ease);
                    }
                  }
                },
                onDragEntered: (details) { },
                onDragExited: (details) { },
                child: DragTarget(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      alignment: Alignment.center,
                      color: select.contains(index) ? Colors.blue : Colors.grey,
                      padding: const EdgeInsets.all(3),
                      child: Image.file(key: items[index].globalKey, File(items[index].imagePath))
                    );
                  },
                  onWillAcceptWithDetails: (details) {
                    return true;
                  },
                  onAcceptWithDetails: (details) {
                    RenderBox rb = items[index].globalKey.currentContext!.findRenderObject() as RenderBox;
                    double half = rb.size.height / 2;
                    double point = rb.globalToLocal(details.offset).dy + 75;
                    
                    int fromIdx = items.indexOf(ItemClass(details.data as String));
                    int toIdx = (point < half) ? index : index + 1;
                    
                    reorderOneItem(fromIdx, toIdx);
                  },
                  onMove: (details) {
                    RenderSliverList rb = context.findRenderObject() as RenderSliverList;
                    double scUp = rb.getAbsoluteSize().height * (1 / 4);
                    double scDown = rb.getAbsoluteSize().height * (3 / 4);

                    double dp = details.offset.dy + 75;
                    double scroll = 0.0;
                    if(dp < scUp) {
                      scroll = sc.offset - 100;
                      if(sc.offset > sc.position.minScrollExtent) {
                        sc.animateTo(scroll, duration: Duration(milliseconds: 200), curve: Curves.linear);
                      }
                    } else if(dp > scDown) {
                      scroll = sc.offset + 100;
                      if(sc.offset < sc.position.maxScrollExtent) {
                        sc.animateTo(scroll, duration: Duration(milliseconds: 200), curve: Curves.linear);
                      }
                    } else {
                      sc.jumpTo(sc.position.pixels);
                    }
                  },
                  // onLeave: (data) {
                  //   sc.jumpTo(sc.position.pixels);
                  // },
                )
              ),
            )
          )
        );
      },
      itemCount: items.length,
      onReorder: (int oldIdx, int newIdx) {
        List tmp = select.toList();
        tmp.sort();

        // 하나의 아이템
        if(!select.contains(oldIdx) || tmp.length <= 1) {
          reorderOneItem(oldIdx, newIdx);
        } else { // 여러 아이템
          List<ItemClass> arr = [];
          int idx = 0;
          for(var i in items) {
            if(!select.contains(idx)) {
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
                newIdx = (newIdx < 0) ? 0 : newIdx;

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
        }

        select.clear();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return makeContainer(context);
  }
}