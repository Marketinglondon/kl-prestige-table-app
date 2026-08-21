class AppConfig {
  // Cloudinary
  static const String cloudinaryCloudName = 'iggcl810';
  static const String cloudinaryUploadPreset = 'klprestige_unsigned';
  static const String cloudinaryUploadUrl =
      'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload';

  // WhatsApp del negocio (reemplaza por el número real, con código de país, sin +, sin espacios)
  static const String whatsappNumber = '50000000000';

  // Nombre del negocio
  static const String appName = 'KL Prestige Table';

  // Categorías fijas del catálogo (deben coincidir EXACTO con index.html)
  static const List<String> categorias = [
    'Mesas',
    'Sillas',
    'Manteles',
    'Centros de Mesa',
    'Iluminación',
    'Decoración',
    'Vajilla',
    'Cristalería',
  ];
}
