import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ItemClass extends Equatable {
  final String imagePath;
  late GlobalKey globalKey;

  ItemClass(this.imagePath) {
    globalKey = GlobalKey();
  }
  
  @override
  List<Object> get props => [imagePath];
}