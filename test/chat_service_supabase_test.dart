import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uprm_professional_portfolio/core/services/chat_service.dart';
import 'package:uprm_professional_portfolio/core/services/chat_service_supabase.dart';

Future<Map<String, String>> _loadConfig() async {
  // inline placeholders (edit here if you don't want a file)
  // NEEDS TO BE FILLED TO BE TESTED
  return <String, String>{
    'SUPABASE_URL': '',
    'SUPABASE_ANON_KEY': '',
    'TEST_EMAIL': '',
    'TEST_PASSWORD': '',
    'TEST_CONVERSATION_ID': '',
  };
}

void main() {
  late SupabaseClient client;
  late ChatServiceSupabase svc;
  var initialized = false;

  late String supabaseUrl;
  late String supabaseAnonKey;
  late String testEmail;
  late String testPassword;
  late String testConversationId;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // allow SharedPreferences without a platform channel
    SharedPreferences.setMockInitialValues({});

    // allow real network calls (disable test HTTP override)
    HttpOverrides.global = null;

    final cfg = await _loadConfig();
    supabaseUrl = cfg['SUPABASE_URL'] ?? '';
    supabaseAnonKey = cfg['SUPABASE_ANON_KEY'] ?? '';
    testEmail = cfg['TEST_EMAIL'] ?? '';
    testPassword = cfg['TEST_PASSWORD'] ?? '';
    testConversationId = cfg['TEST_CONVERSATION_ID'] ?? '';

    expect(supabaseUrl.isNotEmpty, true, reason: 'SUPABASE_URL missing');
    expect(supabaseAnonKey.isNotEmpty, true,
        reason: 'SUPABASE_ANON_KEY missing');
    expect(testEmail.isNotEmpty, true, reason: 'TEST_EMAIL missing');
    expect(testPassword.isNotEmpty, true, reason: 'TEST_PASSWORD missing');
    expect(testConversationId.isNotEmpty, true,
        reason: 'TEST_CONVERSATION_ID missing');

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    client = Supabase.instance.client;
    initialized = true;

    final res = await client.auth.signInWithPassword(
      email: testEmail,
      password: testPassword,
    );
    expect(res.user, isNotNull, reason: 'Test user must exist & be confirmed');

    svc = ChatServiceSupabase(client: client);
  });

  tearDownAll(() async {
    if (initialized) {
      try {
        await client.auth.signOut();
      } catch (_) {}
    }
  });

  group('ChatServiceSupabase', () {
    test('sendMessage inserts and returns a ChatMessage', () async {
      final body = 'hello from test ${Random().nextInt(1 << 20)}';
      final ChatMessage? sent = await svc.sendMessage(testConversationId, body);

      expect(sent, isNotNull);
      expect(sent!.conversationId, equals(testConversationId));
      expect(sent.senderId, equals(client.auth.currentUser!.id));
      expect(sent.text, equals(body));
      expect(sent.id, isNotEmpty);
      expect(sent.timeStamp.isUtc, isTrue);

      final page = await svc.fetchMessages(testConversationId, limit: 20);
      final found = page.any((m) => m.id == sent.id);
      expect(found, isTrue);
    });

    test('fetchMessages returns most recent first and respects limit',
        () async {
      final page = await svc.fetchMessages(testConversationId, limit: 2);
      expect(page.length <= 2, isTrue);
      if (page.length == 2) {
        expect(
            page[0].timeStamp.isAfter(page[1].timeStamp) ||
                page[0].timeStamp.isAtSameMomentAs(page[1].timeStamp),
            isTrue);
      }
    });

    test('fetchMessages with before includes messages older than cutoff',
        () async {
      final sent = await svc.sendMessage(
        testConversationId,
        'before-check ${DateTime.now().microsecondsSinceEpoch}',
      );
      expect(sent, isNotNull);

      final cutoff = sent!.timeStamp.add(const Duration(milliseconds: 1));
      final older = await svc.fetchMessages(testConversationId,
          before: cutoff, limit: 50);
      expect(older.any((m) => m.id == sent.id), isTrue);
    });

    test('fetchMessages handles empty conversationId', () async {
      final page = await svc.fetchMessages('   ');
      expect(page, isEmpty);
    });

    test('sendMessage returns null for empty inputs or no auth', () async {
      expect(await svc.sendMessage('   ', 'x'), isNull);
      expect(await svc.sendMessage(testConversationId, '   '), isNull);

      await client.auth.signOut();
      expect(await svc.sendMessage(testConversationId, 'should fail'), isNull);

      final res = await client.auth.signInWithPassword(
        email: testEmail,
        password: testPassword,
      );
      expect(res.user, isNotNull);
    });
  });
}
