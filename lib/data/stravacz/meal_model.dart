class Meal {
  Meal({
    required this.type,
    required this.name,
    this.selected  =false,
  });

  String type;
  String name;
  bool? selected;
  
  @override
  String toString(){
    return '$type: $name, selected: $selected';
  }
}
