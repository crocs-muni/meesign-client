import 'dart:math';

class RndNameGenerator {
  // https://github.com/imsky/wordlists

  static const List<String> _adjectives = [
    'arctic',
    'arid',
    'breezy',
    'calm',
    'chilly',
    'cloudy',
    'cold',
    'cool',
    'damp',
    'dark',
    'dry',
    'foggy',
    'freezing',
    'frosty',
    'great',
    'hot',
    'humid',
    'icy',
    'light',
    'mild',
    'nice',
    'overcast',
    'rainy',
    'smoggy',
    'snowy',
    'sunny',
    'warm',
    'windy',
    'wintry'
  ];

  static const List<String> _nouns = [
    'alternator',
    'booster',
    'bumper',
    'cabin',
    'caliper',
    'canister',
    'clutch',
    'compressor',
    'condenser',
    'converter',
    'crankshaft',
    'cylinder',
    'differential',
    'door',
    'drivetrain',
    'filter',
    'gearbox',
    'heater',
    'joint',
    'light',
    'manifold',
    'mirror',
    'motor',
    'muffler',
    'rack',
    'radiator',
    'rotor',
    'sensor',
    'starter',
    'strut',
    'switch',
    'transmission',
    'valve',
    'wheel',
  ];

  final _rnd = Random();

  String _choose(List<String> items) => items[_rnd.nextInt(items.length)];

  String next() => _choose(_adjectives) + ' ' + _choose(_nouns);
}
