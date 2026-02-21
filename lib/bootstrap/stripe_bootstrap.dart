import 'stripe_bootstrap_stub.dart'
    if (dart.library.io) 'stripe_bootstrap_io.dart' as impl;

Future<void> initializeStripe() => impl.initializeStripe();
