import 'fauna_repository.dart';
import 'post.dart';

class PostRepository extends FaunaRepository<Post> {

  PostRepository() : super("posts", "all_posts");
//  PostRepository() : super("Letters", "all_letters");



}