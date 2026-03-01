class AppUrl {
  // Base URLs for production
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.collaby.co',
  );
  // static const String baseUrl = 'https://2e929a9ed5d4.ngrok-free.app';

  // ------------------ Auth Endpoints ------------------
  // Login endpoint
  static String login() => '$baseUrl/auth/login';
  static String loginWithGoogle() =>
      '$baseUrl/auth/google/token-login?role=creator';
  static String loginWithApple() =>
      '$baseUrl/auth/apple/token-login?role=creator';
  // Register endpoint
  static String register() => '$baseUrl/auth/register/creator';

  // Token verification endpoint
  static String verifyToken() => '$baseUrl/auth/verify-token';

  // OTP send endpoint
  static String otpSend() => '$baseUrl/auth/creator-email-resend';
  // OTP verification endpoint
  static String verifyOtp() => '$baseUrl/auth/creator-email-verify';
  // OTP send To No endpoint
  static String phoneOtpSend() => '$baseUrl/auth/creator-phone-send-otp';
  // Phone OTP Verification endpoint
  static String phoneVerifyOtp() => '$baseUrl/auth/creator-phone-verify';

  // Forgot password endpoint
  static String forgotPassword() => '$baseUrl/auth/forgot-password';

  // Forgot OTP Verification endpoint
  static String verifyForgotOtp() => '$baseUrl/auth/verify-otp';

  // Change password endpoint
  static String resetPassword() => '$baseUrl/auth/reset-password';

  // Profile Setup endpoint
  static String profileSetup() => '$baseUrl/creator/profile/setup';

  // Upload Media To S3 endpoint
  static String uploadMedia() => '$baseUrl/s3/upload-media';

  // Gig Creation endpoint
  static String gigCreationAfterSetUp() => '$baseUrl/gig/after-setup';

  // Gig Creation endpoint
  static String updateGig(String gigId) => '$baseUrl/gig/$gigId';

  // Gig endpoints
  static String myGigs() => '$baseUrl/gig/my-gigs';

  static String gigDetail(String gigId) => '$baseUrl/gig/$gigId';

  static String updateGigStatus(String gigId) => '$baseUrl/gig/$gigId/status';

  static String deleteGig(String gigId) => '$baseUrl/gig/$gigId';

  static String jobsAll() => '$baseUrl/jobs/all';
  static String jobDetails(String jobId) => '$baseUrl/jobs/$jobId';

  static String addFavorite(String jobId) => '$baseUrl/favourites/jobs/$jobId';
  static String removeFavorite(String jobId) =>
      '$baseUrl/favourites/jobs/$jobId';
  static String submitInterest(String jobId) =>
      '$baseUrl/jobs/$jobId/interests';
  static String toggleFavorite(String jobId) =>
      '$baseUrl/favourites/jobs/$jobId';

  // Orders API Endpoints

  /// Get creator orders with query parameters
  static String getCreatorOrders(Map<String, dynamic>? queryParams) {
    String url = '$baseUrl/orders/creator';

    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      url += '?$queryString';
    }

    return url;
  }

  static String getOrderRequest(String orderId) =>
      '$baseUrl/orders/$orderId/request-view';

  static String getNotification(String orderId) => '$baseUrl/notification';

  static String notifications(int page, int limit) =>
      '$baseUrl/notification?page=$page&limit=$limit';

  /// Accept an order
  static String acceptOrder(String orderId) {
    return '$baseUrl/orders/$orderId/status';
  }

  /// Decline an order
  static String declineOrder(String orderId) {
    return '$baseUrl/orders/$orderId/status';
  }

  /// Get order details
  static String getOrderDetails(String orderId) {
    return '$baseUrl/orders/$orderId';
  }

  /// Get order TimeLines
  static String getOrderTimeLines(String orderId) {
    return '$baseUrl/orders/$orderId/activity';
  }

  /// Get order Deliveries
  static String getOrderDeliveries(String orderId) {
    return '$baseUrl/orders/$orderId/deliveries';
  }

  /// Submit order deliverable
  static String deliverOrder(String orderId) =>
      '$baseUrl/orders/$orderId/deliver';

  /// Request revision
  static String requestRevision(String orderId) {
    return '$baseUrl/orders/$orderId/revision';
  }

  /// Get order messages/chat
  static String getOrderMessages(String orderId) {
    return '$baseUrl/orders/$orderId/messages';
  }

  /// Send message for an order
  static String sendOrderMessage(String orderId) {
    return '$baseUrl/orders/$orderId/messages';
  }

  //Profile End Point

  static const String creatorProfileUrl = '$baseUrl/creator/profile';
  static const String updateCreatorProfile = '$baseUrl/user/creator/profile';
  static const String hidePortfolioItemUrl = '$baseUrl/creator/portfolio/hide';

  // Boost endpoints
  static const String getBoostPlans = '$baseUrl/boost/plans';
  static const String purchaseBoost = '$baseUrl/boost/purchase';
  static const String boostProfile = '$baseUrl/boost/profile';
  static const String boostCancel = '$baseUrl/boost/cancel';

  // Logout and delete endpoint
  static String logout() => '$baseUrl/auth/logout';
  static String deleteAccount() => '$baseUrl/creator/delete-account';

  static String withdrawalHistory({int page = 1, int limit = 10}) {
    return '$baseUrl/payment/wallet/withdrawal-history?page=$page&limit=$limit';
  }

  static String withdrawalFees() => '$baseUrl/payment/withdrawal-fees';

  static String bankAccounts() {
    return '$baseUrl/payment/wallet/bank-accounts';
  }

  static String connectedAccount() {
    return '$baseUrl/payment/stripe/connected-account';
  }

  static String withdraw() {
    return '$baseUrl/payment/wallet/withdraw';
  }

  // Support tickets
  static String createSupportTicket() => '$baseUrl/support-tickets';

  static String getMySupportTickets(Map<String, dynamic>? queryParams) {
    String url = '$baseUrl/support-tickets/me';
    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      url += '?$queryString';
    }
    return url;
  }

  static String getMySupportTicket(String ticketId) =>
      '$baseUrl/support-tickets/me/$ticketId';

  static String replyMySupportTicket(String ticketId) =>
      '$baseUrl/support-tickets/me/$ticketId/replies';
}
