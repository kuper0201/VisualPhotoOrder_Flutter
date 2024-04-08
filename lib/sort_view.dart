import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter_application_1/split_views/lower_split.dart';
import 'package:flutter_application_1/split_views/upper_split.dart';
import 'package:split_view/split_view.dart';

import 'side_image_view.dart';

class SortView extends StatefulWidget {
  static const routeName = '/sort_view';

  const SortView({Key? key}) : super(key: key);

  @override
  SortViewState createState() => SortViewState();
}

class SortViewState extends State<SortView> {
  double weight = 0.2;

  @override
  Widget build(BuildContext context) {
    DesktopWindow.setWindowSize(const Size(900, 600));

    return SplitView(
      children: [UpperSplitView(), LowerSplitView()],
      viewMode: SplitViewMode.Vertical,
      indicator: const SplitIndicator(viewMode: SplitViewMode.Vertical),
      activeIndicator: const SplitIndicator(
        viewMode: SplitViewMode.Vertical,
        isActive: true,
      ),
      controller: SplitViewController(weights: [null, weight], limits: [null, WeightLimit(min:0.1, max: 0.3)]),
      onWeightChanged: (w) {
        double? wei = List.of(w)[1];
        if(wei != null) {
          weight = wei;
        } else {
          weight = 0.2;
        }
      },
    );
  }
}