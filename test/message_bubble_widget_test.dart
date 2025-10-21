import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uprm_professional_portfolio/features/chat/widgets/message_bubble.dart';

void main() {
  testWidgets('MessageBubble renders text and timestamp', (WidgetTester tester) async {
    final ts = DateTime.now().subtract(const Duration(minutes: 5));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: const [],
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            text: 'Hello world',
            timestamp: ts,
            isCurrentUser: true,
            status: MessageStatus.sent,
          ),
        ),
      ),
    );

    expect(find.text('Hello world'), findsOneWidget);
    expect(find.byType(MessageBubble), findsOneWidget);
  });
}
