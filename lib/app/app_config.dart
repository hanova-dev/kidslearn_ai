/// The one place for model IDs, endpoints, secret keys and limits.
class AppConfig {
  // ── Model IDs ──
  static const String storyModelId = 'openai/gpt-oss-120b';
  static const String speechModelId = 'whisper-large-v3';
  static const String imageModelId = '@cf/black-forest-labs/flux-1-schnell';

  // ── Endpoints ──
  static const String groqChatUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String groqTranscriptionUrl =
      'https://api.groq.com/openai/v1/audio/transcriptions';
  static const String cloudflareAccountsUrl =
      'https://api.cloudflare.com/client/v4/accounts';

  // ── Secret keys (from env/dev.json at build time) ──
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String cloudflareAccountId = String.fromEnvironment(
    'CLOUDFLARE_ACCOUNT_ID',
  );
  static const String cloudflareApiToken = String.fromEnvironment(
    'CLOUDFLARE_API_TOKEN',
  );

  // ── Limits (NFR-REL-02) ──
  static const Duration requestTimeout = Duration(seconds: 15);
  static const int maxRetries = 2;
  static const int scenesPerStory = 6;
  static const int imageSteps = 4;

  /// True when all keys were passed with --dart-define-from-file.
  static bool get hasAllKeys {
    return groqApiKey.isNotEmpty &&
        cloudflareAccountId.isNotEmpty &&
        cloudflareApiToken.isNotEmpty;
  }
}
