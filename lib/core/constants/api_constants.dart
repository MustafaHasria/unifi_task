class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://gorest.co.in/public/v2';
  
  // Bearer Token
  static const String bearerToken =
      '82fc1a11d403f8709daa5b98093089dbd23141da091abb443ce482ca898a3915';
  
  // Endpoints
  static const String usersEndpoint = '/users';
  
  // Pagination
  static const int defaultPerPage = 20;
  static const int defaultPage = 1;
  
  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

