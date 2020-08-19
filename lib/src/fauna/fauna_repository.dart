import 'package:fauna_db_client/src/fauna/identity_factory.dart';
import 'package:fauna_db_client/src/fauna/pagination_option.dart';
import 'package:fauna_db_client/src/fauna/repository.dart';
import 'package:faunadb_http/faunadb_http.dart';
import 'package:faunadb_http/query.dart';
import 'package:optional/optional_internal.dart';

import 'entity.dart';

 abstract class FaunaRepository<T extends Entity> implements Repository<T>, IdentityFactory {
  final String collection;
  final String all_items_index;

  FaunaRepository(this.collection, this.all_items_index);

  FaunaClient _client() => FaunaClient(FaunaConfig.build(secret: ""));

  @override
  Future<String> nextId() {
    final FaunaClient client = _client();
    Future<String> id = client.query(
        NewId()
    ).then((value) {
      return value.toJson()["resource"];
    });

    client.close();

    return id;
  }

  @override
  Future<T> save(T entity, {Function function})  {
    final FaunaClient client = _client();
    Future<T> result = client.query(
        saveQuery(entity.getId() , Obj(entity.model()))
    ).then((value) {
      Map<String,dynamic> data = value.toJson();
      final resource = data["resource"];
      T t =  function(resource["data"].object);
      return t;
    });

    client.close();
    return result;
  }

  Future<Optional<T>> remove(String id, {Function function}) {
    final FaunaClient client = _client();
    Future<Optional<T>> result = client.query(
      Delete(
          Ref(Collection(collection), id)
      )
    ).then((value) {
      Map<String,dynamic> data = value.toJson();
      final resource = data["resource"];
      if(resource != null) {
        T t =  function(resource["data"].object);
        return Optional.of(t);
      }
      return Optional.ofNullable(null);
    });

    client.close();
    return result;
  }

  Future<Optional<T>> find(String id, {Function function}) {
     final FaunaClient client = _client();
     Future<Optional<T>> result = client.query(
       Get(Ref(Collection(collection), id))
     ).then((value) {
       Map<String,dynamic> data = value.toJson();
       final resource = data["resource"];
       if(resource != null) {
         T t =  function(resource["data"].object);
         return Optional.of(t);
       }
       return Optional.ofNullable(null);
     });
     client.close();
     return result;
  }

  Expr saveQuery(String id, Expr data) {
    Expr query =If(
            Exists(Ref(Collection(collection), id)),
            Replace(Ref(Collection(collection), id), Obj({"data": data})),
            Create(Ref(Collection(collection), id), Obj({"data": data}))
        );
    return query;
  }

  @override
  Future<Page> findAll(PaginationOptions po, {Function function}) {
    final FaunaClient client = _client();
    Paginate paginate = _paginate(po);
    Future<Page> result = client.query(
      Map_(
          paginate,
          Lambda("nextRef", Select("data", Get(Var("nextRef"))))
      )
    ).then((value) {
      Map<String,dynamic> data = value.toJson();
      print(data);
      final resource = data["resource"];
      List<T> listResult = List();
      Page pageResult;
      if(resource != null) {
        List dataObjects = resource["data"];
        for(var item in dataObjects) {
          print(item);
         T t =  function(item.toJson());
         listResult.add(t);
        }
      }
      print(listResult);

      var after = null;//resource["after"]?.length > 0 ? resource["after"][0] : null;
      var before = null;//resource["before"]?.length() > 0 ? resource["before"][0] : null;
      pageResult = Page(before, after, listResult);
      return pageResult;
    });
    client.close();
    return result;
    //Lambda(Value("nextRef"), Select(Value("data"), Get(Var("nextRef"))))
  }

  Paginate _paginate(PaginationOptions op) {
    if(op.size?.isNotEmpty && op.before?.isNotEmpty && op.after?.isNotEmpty) {
      int size = op.size.value;
      Object before = Ref(Collection(collection), op.before.value);
      Object after = Ref(Collection(collection), op.after.value);
      return Paginate(Match(Index(this.all_items_index)), size: size, before: before, after: after );
    } //Paginate(Match(Index("all_letters")))

    if(op.size?.isNotEmpty && op.after?.isNotEmpty) {
      int size = op.size.value;
      Object after = Ref(Collection(collection), op.after.value);
      return Paginate(Match(Index(this.all_items_index)), size: size, after: after );
    }

    if(op.size?.isNotEmpty && !op.before?.isNotEmpty && !op.after?.isNotEmpty) {
      int size = op.size.value;
      return Paginate(Match(Index(this.all_items_index)), size: size );
    }

    if(!op.size?.isNotEmpty && !op.before?.isNotEmpty && !op.after?.isNotEmpty) {
      return Paginate(Match(Match(Index(this.all_items_index))));
    }
  }
}