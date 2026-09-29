class AppConfig {
  AppConfig._();

  // Leave empty for Demo/Offline mode.
  // Never commit a real production API key to source control.
  static const geminiApiKey = '';

  // Replace with a currently supported Gemini model if needed.
  // Keeping this value here makes the AI service easy to change later.
  static const geminiModel = 'gemini-2.5-flash-lite';

  static const geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models';
}
