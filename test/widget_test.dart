// Basic smoke test for Jawan Delivery.
//
// This app starts on the auth screen when no user is logged in, so the
// test verifies that screen renders correctly instead of the default
// counter-app template test that ships with `flutter create`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jawan_delivery/app.dart';

void main() {
  testWidgets('Shows the auth screen on a fresh launch', (WidgetTester tester) async {
    await tester.pumpWidget(const JawanDeliveryApp());

    expect(find.text('جوان للتوصيل'), findsOneWidget);
    expect(find.text('تسجيل دخول'), findsOneWidget);
    expect(find.text('إنشاء حساب'), findsOneWidget);
  });
}
