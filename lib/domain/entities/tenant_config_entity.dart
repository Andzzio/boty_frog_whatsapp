/// Entity representing the configuration of a tenant.
class TenantConfigEntity {
  /// Constructs a [TenantConfigEntity] instance.
  TenantConfigEntity({
    required this.businessId,
    required this.phoneId,
    required this.apiToken,
    required this.verifyToken,
    required this.aiApiKey,
    required this.brandName,
    required this.catalogUrl,
    required this.businessType,
    required this.toneStyle,
    required this.botName,
  });

  /// The unique identifier of the business.
  final String businessId;

  /// The WhatsApp phone number ID.
  final String phoneId;

  /// The WhatsApp API access token.
  final String apiToken;

  /// The WhatsApp webhook verification token.
  final String verifyToken;

  /// The AI model API Key.
  final String aiApiKey;

  /// The name of the brand.
  final String brandName;

  /// The catalog URL.
  final String catalogUrl;

  /// The type of business.
  final String businessType;

  /// The style of tone for the chatbot responses.
  final String toneStyle;

  /// The name of the bot.
  final String botName;
}
