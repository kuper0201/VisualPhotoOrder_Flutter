import 'dart:io';

import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter_application_1/Model/ItemClass.dart';
import 'package:flutter_application_1/side_image_view.dart';
import 'package:flutter_application_1/sort_view.dart';
import 'package:split_view/split_view.dart';

class UpperSplitView extends StatefulWidget {
  const UpperSplitView({Key? key}) : super(key: key);

  @override
  UpperSplitViewState createState() => UpperSplitViewState();
}

class UpperSplitViewState extends State<UpperSplitView> {
  String selectedImg = "";
  double weight = 0.8;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    selectedImg = args['path_list'][0].imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return ContextMenuOverlay(
      buttonStyle: ContextMenuButtonStyle(
        fgColor: Colors.green,
        bgColor: Colors.red.shade100,
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
            const Center(child: SideImageView()),
            Center(child: Image.file(File(selectedImg))),
          ],
        )
      ),
    );
  }
}