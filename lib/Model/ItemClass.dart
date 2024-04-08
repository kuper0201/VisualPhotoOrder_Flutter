import 'package:equatable/equatable.dart';

class ItemClass extends Equatable {
  final String imagePath;
  ItemClass(this.imagePath);
  
  @override
  List<Object> get props => [imagePath];
}