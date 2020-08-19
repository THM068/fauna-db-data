
import 'dart:core';

abstract class Entity {
   String id = "0";

   String getId() {
    return id;
  }

   void setId(String id) {
    this.id = id;
  }

  Map<String, dynamic> model();
}