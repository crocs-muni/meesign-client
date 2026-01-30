import 'package:test/expect.dart';

const allEqual = AllEqualMatcher();

// TODO(dev): make sure the behavior of the matcher is sane
// (good mismatch messages etc.)
class AllEqualMatcher extends Matcher {
  const AllEqualMatcher();

  @override
  Description describe(Description description) => description.add('all equal');

  @override
  bool matches(Object? item, Map<Object?, Object?> matchState) {
    if (item is! Iterable) return false;
    final matcher = everyElement(item.first);
    return matcher.matches(item, matchState);
  }
}
