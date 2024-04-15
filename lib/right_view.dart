import 'dart:io';

import 'package:flutter/material.dart';
import 'package:split_view/split_view.dart';

class RightView extends StatefulWidget {
  const RightView({Key? key, required this.selectedImg}) : super(key: key);
  final String selectedImg;

  @override
  RightViewState createState() => RightViewState();
}

class RightViewState extends State<RightView> {
  double weight = 0.2;

  @override
  Widget build(BuildContext context) {
    return SplitView(
      viewMode: SplitViewMode.Vertical,
      indicator: const SplitIndicator(viewMode: SplitViewMode.Vertical),
      activeIndicator: const SplitIndicator(
        viewMode: SplitViewMode.Vertical,
        isActive: true,
      ),
      controller: SplitViewController(weights: [null, weight], limits: [null, WeightLimit(min:0.2, max: 0.3)]),
      onWeightChanged: (w) {
        double? wei = List.of(w)[1];
        if(wei != null) {
          weight = wei;
        } else {
          weight = 0.2;
        }
      },
      children: [
        widget.selectedImg.isEmpty ? const Center(child: Text("이미지를 선택하세요")) : Draggable(
          data: widget.selectedImg,
          feedback: SizedBox(width: 150, height: 150, child: Center(child: Image.file(File(widget.selectedImg), opacity: const AlwaysStoppedAnimation(0.7)))),
          dragAnchorStrategy: (draggable, context, position) {
            return const Offset(75, 75);
          },
          child: Padding(padding: const EdgeInsets.all(5), child: Center(child: Image.file(File(widget.selectedImg))))
        ),
        Container()
      ],
    );
  }
}