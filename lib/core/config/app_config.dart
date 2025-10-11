class AppConfig {
  static const String appName = 'Club Management';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Student Activity & Club Management Platform';
  
  // API Configuration
  static const String baseUrl = 'https://api.clubmanagement.com';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Firebase Configuration
  static const String firebaseProjectId = 'club-management-app';
  
  // Storage Configuration
  static const String storageUrl = 'gs://club-management-app.appspot.com';
  static const String profileImagesPath = 'profile_images';
  static const String clubLogosPath = 'club_logos';
  static const String eventBannersPath = 'event_banners';
  
  // App Configuration
  static const int maxImageSizeMB = 5;
  static const int leaderboardLimit = 10;
  static const int eventsPerPage = 20;
  static const int clubsPerPage = 20;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Colors
  static const int primaryColorValue = 0xFF6366F1;
  static const int secondaryColorValue = 0xFF8B5CF6;
  static const int successColorValue = 0xFF10B981;
  static const int warningColorValue = 0xFFF59E0B;
  static const int errorColorValue = 0xFFEF4444;
}
