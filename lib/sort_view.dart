import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter_application_1/Model/ItemSingleton.dart';
import 'package:flutter_application_1/right_view.dart';
import 'package:flutter_application_1/left_view.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:split_view/split_view.dart';

class SortView extends StatefulWidget {
  static const routeName = '/sort_view';
  const SortView({Key? key}) : super(key: key);

  @override
  SortViewState createState() => SortViewState();
}

class SortViewState extends State<SortView> {
  String selectedImg = "";
  double weight = 0.8;

  @override
  void initState() {
    super.initState();
    DesktopWindow.setWindowSize(const Size(900, 600));

    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('프로그램을 종료하시겠습니까?\n저장되지 않은 사항은 사라집니다.'),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  await ItemSingleton().saveAll(context, "");
                  if(context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text('저장')
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('저장 안함')
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소')
              ),
            ]
          );
        }
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {    
    return ContextMenuOverlay(
      buttonStyle: const ContextMenuButtonStyle(
        fgColor: Colors.red,
        hoverBgColor: Colors.red,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: SplitView(
          viewMode: SplitViewMode.Horizontal,
          indicator: const SplitIndicator(viewMode: SplitViewMode.Horizontal),
          activeIndicator: const SplitIndicator(
            viewMode: SplitViewMode.Horizontal,
            isActive: true,
          ),
          controller: SplitViewController(weights: [null, weight], limits: [null, WeightLimit(min:0.6, max: 0.9)]),
          onWeightChanged: (w) {
            double? wei = List.of(w)[1];
            if(wei != null) {
              weight = wei;
            } else {
              weight = 0.8;
            }
          },
          children: [
            const Center(child: LeftView()),
            RightView(selectedImg: selectedImg)
          ],
        )
      )
    );
  }
}