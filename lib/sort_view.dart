import 'dart:io';

import 'package:flutter/material.dart';
import 'package:context_menus/context_menus.dart';
import 'package:split_view/split_view.dart';

import 'side_image_view.dart';

class SortView extends StatefulWidget {
  static const routeName = '/sort_view';

  const SortView({Key? key}) : super(key: key);

  @override
  SortViewState createState() => SortViewState();
}

class SortViewState extends State<SortView> {
  String selectedImg = "";
  double weight = 0.6;

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
              weight = 0.6;
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