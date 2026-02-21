import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> initializeStripe() async {
  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }

  Stripe.publishableKey =
      'pk_test_51SXGtqEC0R7ZrnKnZCRrvuGK7lBeUFefObcBR5PToQy2VX8oV7iVIcbrsUoaEYb1ERLrun8Ot63EiYHx1O33K2o900hw6b7jTs';
  await Stripe.instance.applySettings();
}
