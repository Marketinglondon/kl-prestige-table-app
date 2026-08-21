class AppConfig {
  // Cloudinary
  static const String cloudinaryCloudName = 'iggcl810';
  static const String cloudinaryUploadPreset = 'klprestige_unsigned';
  static const String cloudinaryUploadUrl =
      'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload';

  // WhatsApp del negocio
  static const String whatsappNumber = '447549679289';

  // Nombre del negocio
  static const String appName = 'KL Prestige Table';

  // Categorías fijas del catálogo (deben coincidir EXACTO con index.html)
  static const List<String> categorias = [
    'Tables',
    'Chairs',
    'Tablecloths',
    'Centerpieces',
    'Lighting',
    'Decoration',
    'Tableware',
    'Glassware',
  ];
}
