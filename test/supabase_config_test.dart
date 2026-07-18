import 'package:flutter_test/flutter_test.dart';
import 'package:verdict/core/services/supabase_config.dart';

void main() {
  test('requires both URL and publishable key', () {
    expect(
      const SupabaseConfig(url: '', publishableKey: 'key').isConfigured,
      isFalse,
    );
    expect(
      const SupabaseConfig(
        url: 'https://example.supabase.co',
        publishableKey: 'key',
      ).isConfigured,
      isTrue,
    );
  });
}
