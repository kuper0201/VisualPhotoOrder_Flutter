import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Model/ItemClass.dart';
import 'package:flutter_application_1/sort_view.dart';

class LeftView extends StatefulWidget {
  const LeftView({Key? key}) : super(key: key);

  @override
  LeftViewState createState() => LeftViewState();
}

class LeftViewState extends State<LeftView> {
  List<ItemClass> items = [];
  Set select = {};
  Timer? _timer;
  ScrollController sc = ScrollController();

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

  void reorderMultiItems(int oldIdx, int newIdx) {
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
  }

  void stopTimer() {
    if(_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
    }
  }

  void scrollUp() {
    _timer ??= Timer.periodic(const Duration(milliseconds: 10), (t) {
      if(sc.offset - 1 >= sc.position.minScrollExtent) sc.jumpTo(sc.offset - 5);
    });
  }

  void scrollDown() {
    _timer ??= Timer.periodic(const Duration(milliseconds: 10), (t) {
      if(sc.offset + 1 <= sc.position.maxScrollExtent) sc.jumpTo(sc.offset + 5);
    });
  }

  ReorderableListView makeContainer(BuildContext context) {
    SortViewState? parent = context.findAncestorStateOfType<SortViewState>();

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
                  stopTimer();

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
                    scrollUp();
                  } else if(dp > scDown) {
                    scrollDown();
                  } else {
                    stopTimer();
                  }
                },
                onDragEntered: (details) { },
                onDragExited: (details) {
                  stopTimer();
                },
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
                    stopTimer();
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
                      scrollUp();
                    } else if(dp > scDown) {
                      scrollDown();
                    } else {
                      stopTimer();
                    }
                  },
                  onLeave: (data) {
                    stopTimer();
                  },
                )
              ),
            )
          )
        );
      },
      itemCount: items.length,
      onReorder: (int oldIdx, int newIdx) {
        reorderMultiItems(oldIdx, newIdx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return makeContainer(context);
  }
}