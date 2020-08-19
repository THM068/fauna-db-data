
abstract class IdentityFactory {

/**
 * It returns a unique valid Id.
 *
 * @return a unique valid Id
 */
Future<String> nextId();

/**
 * It returns a List of unique valid Ids with the given size.
 *
 * @param size the number of unique Ids to return
 * @return a List of unique valid Ids
 */
//Future<List<String>> nextIds(int size);
}