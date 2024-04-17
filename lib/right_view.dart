import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Model/ItemSingleton.dart';
import 'package:split_view/split_view.dart';

class RightView extends StatefulWidget {
  const RightView({Key? key, required this.selectedImg}) : super(key: key);
  final String selectedImg;

  @override
  RightViewState createState() => RightViewState();
}

class RightViewState extends State<RightView> {
  TextEditingController tc = TextEditingController();
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
          dragAnchorStrategy: (draggable, context, position) { return const Offset(75, 75); },
          child: Padding(padding: const EdgeInsets.all(5), child: Center(child: Image.file(File(widget.selectedImg))))
        ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text("파일명", style: TextStyle(fontSize: 18),),
                  ),
                  Expanded(
                    flex: 7,
                    child: TextField(
                      controller: tc,
                      maxLines: 1,
                      inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')) ],
                      decoration: const InputDecoration(hintText: "파일명 입력"))
                  )
                ],
              ),
            ),
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 20),
                          padding: const EdgeInsets.all(3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3)
                          ),
                          minimumSize: const Size.fromHeight(50)
                        ),
                        onPressed:() {
                          ItemSingleton().saveAll(context, tc.text);
                        },
                        child: const Text("저장 후 폴더 열기")
                      )
                    )
                  )
                ],
              )
            )
          ],
        )
      ],
    );
  }
}