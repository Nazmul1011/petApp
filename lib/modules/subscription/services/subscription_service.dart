import 'package:petapp/core/services/base_api_service.dart';
import 'package:petapp/core/services/base_api_response.dart';

class SubscriptionService extends BaseService {
  /// Fetches the current subscription summary for the user.
  Future<BaseApiResponse<Map<String, dynamic>>> getSummary() async {
    return safeRequest(
      request: () => api.get('/subscription'),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Starts the one-time 7-day free trial (no payment required).
  Future<BaseApiResponse<Map<String, dynamic>>> startFreeTrial() async {
    return safeRequest(
      request: () => api.post('/subscription/trial'),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Creates a Polar checkout session for the selected plan.
  /// [plan] should be "YEARLY_REGULAR" or "YEARLY_STANDARD".
  Future<BaseApiResponse<Map<String, dynamic>>> createCheckoutSession({
    required String plan,
    String? successUrl,
    String? cancelUrl,
  }) async {
    return safeRequest(
      request: () => api.post(
        '/subscription/polar/checkout',
        data: {
          'plan': plan,
          if (successUrl != null) 'successUrl': successUrl,
          if (cancelUrl != null) 'cancelUrl': cancelUrl,
        },
      ),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Validates a Polar subscription after a successful checkout.
  Future<BaseApiResponse<Map<String, dynamic>>> validateSubscription({
    required String checkoutId,
  }) async {
    return safeRequest(
      request: () => api.post(
        '/subscription/polar/validate',
        data: {'checkoutId': checkoutId},
      ),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
