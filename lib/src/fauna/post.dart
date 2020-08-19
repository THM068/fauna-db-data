import 'package:json_annotation/json_annotation.dart';

import 'entity.dart';

part 'post.g.dart';
@JsonSerializable(nullable: false)
class Post extends Entity{
  final String name;
  final String age;
  final String id;

  Post({this.id,this.name, this.age});

  @override
  Map<String, dynamic> model() {
    return {
      "id": id,
      "name": this.name,
      "age": this.age
    };
  }

}

Post getPostFromJson(Map<String, dynamic> json) {
  return _$PostFromJson(json);
}