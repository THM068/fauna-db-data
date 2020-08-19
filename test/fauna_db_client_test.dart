import 'package:fauna_db_client/fauna_db_client.dart';
import 'package:fauna_db_client/src/fauna/PostRepository.dart';
import 'package:fauna_db_client/src/fauna/pagination_option.dart';
import 'package:fauna_db_client/src/fauna/post.dart';
import 'package:faunadb_http/faunadb_http.dart';
import 'package:optional/optional.dart';
import 'package:test/test.dart';

void main() {
  PostRepository postRepository = PostRepository();
  
  test('Test if next id can can be generated', () async {
    String id = await postRepository.nextId();
    expect(id, isNotEmpty);
  });

  test("A post can be saved to fauna with an id",() async {
    Post postResult = await postRepository.nextId().then((id) {
      Post p = Post(id: id,name: "Thomas", age: "2" );
      return p;
    }).then((post){
      return postRepository.save(post, function: getPostFromJson);
    });

    expect(postResult.id, isNotEmpty);
    expect(postResult.name, "Thomas");
    expect(postResult.age, "2");
  });
  
  test("A post can be removed from fauna",() async {
    Optional<Post> optionalResult =  await postRepository.remove("274263123962102278", function: getPostFromJson);
    expect(optionalResult.isNotEmpty, true);
  });

  test("All result can be returned", () async {
    PaginationOptions paginationOptions = PaginationOptions();
    paginationOptions.size = Optional.of(3);
    paginationOptions.after = Optional.ofNullable(null);
    paginationOptions.before = Optional.ofNullable(null);

    Page result = await postRepository.findAll(paginationOptions, function: getPostFromJson);
    expect(result.data.length, 3);
    prints(result.data);
  });


}
