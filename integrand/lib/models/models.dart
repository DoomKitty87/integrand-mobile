import 'package:flutter/foundation.dart';

class Models extends ChangeNotifier {
  // Put your models here

  late ExampleModel example;
  // late ExampleModel example1;
  // late ExampleModel example2;
  // late ExampleModel example3;
  
  Models() {
    example = ExampleModel(notifyListeners);
    // example1 = ExampleModel(notifyListeners);
    // example2 = ExampleModel(notifyListeners);
    // example3 = ExampleModel(notifyListeners);
  }
}

class ModelBase {
  Function onUpdate;
  ModelBase(this.onUpdate);
  void updateViews() {
    onUpdate();
  }
}

class ExampleModel extends ModelBase {
  ExampleModel(super.onUpdate);

  String string = "Example Value";
  int number = 42;
  bool isActive = true;

  void fetchFromFakeApi() {
    // Simulate an API call
    Future.delayed(Duration(seconds: 2), () {
      string = "Updated Value";
      number = 100;
      isActive = false;
      updateViews();
    });
  }
}