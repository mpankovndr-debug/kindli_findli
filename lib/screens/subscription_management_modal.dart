import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Modal for managing active Intended+ subscription
/// Shows subscription details and opens App Store for management
class SubscriptionManagementModal extends StatelessWidget {
  final String plan;
  final String price;
  final String renewalDate;

  const SubscriptionManagementModal({
    super.key,
    this.plan = 'Yearly',
    this.price = '€39.99/year',
    this.renewalDate = 'March 14, 2027',
  });

  Future<void> _openAppStoreSubscriptions() async {
    HapticFeedback.mediumImpact();

    // iOS App Store subscriptions URL
    final uri = Uri.parse('https://apps.apple.com/account/subscriptions');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF504638).withOpacity(0.28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            constraints: const BoxConstraints(maxWidth: 384),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(0.0, 2.41), // 145° angle
                      end: Alignment(0.0, -2.41),
                      colors: [
                        Color.fromRGBO(245, 236, 224, 0.96),
                        Color.fromRGBO(237, 228, 216, 0.93),
                        Color.fromRGBO(230, 221, 209, 0.95),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF32281E).withOpacity(0.4),
                        blurRadius: 70,
                        offset: const Offset(0, 25),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFFFFF).withOpacity(0.6),
                        blurRadius: 0,
                        offset: const Offset(0, 1),
                        spreadRadius: 0,
                        blurStyle: BlurStyle.inner,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Column(
                        children: [
                          const Text(
                            'Intended+',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3C342A),
                              letterSpacing: -0.4,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You\'re a supporter ♥',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF8A7563),
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Plan Details Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.fromRGBO(255, 255, 255, 0.45),
                                  Color.fromRGBO(248, 245, 242, 0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFFFFFF).withOpacity(0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3C342A).withOpacity(0.1),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: const Color(0xFFFFFFFF).withOpacity(0.5),
                                  blurRadius: 0,
                                  offset: const Offset(0, 1),
                                  spreadRadius: 0,
                                  blurStyle: BlurStyle.inner,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Plan row
                                _buildDetailRow('Plan', plan),

                                const SizedBox(height: 16),

                                // Divider
                                Container(
                                  height: 1,
                                  color: const Color(0xFF8B7563).withOpacity(0.15),
                                ),

                                const SizedBox(height: 16),

                                // Price row
                                _buildDetailRow('Price', price),

                                const SizedBox(height: 16),

                                // Divider
                                Container(
                                  height: 1,
                                  color: const Color(0xFF8B7563).withOpacity(0.15),
                                ),

                                const SizedBox(height: 16),

                                // Renewal row
                                _buildDetailRow('Renews', renewalDate),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Thank you message
                      const Text(
                        'Thank you for supporting Intended.\nYour subscription helps us keep\nbuilding a kinder way to grow.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF8B7563),
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Primary button - Manage in App Store
                      SizedBox(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromRGBO(139, 117, 99, 0.92),
                                    Color.fromRGBO(122, 107, 95, 0.88),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF8B7563).withOpacity(0.4),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3C342A).withOpacity(0.3),
                                    blurRadius: 24,
                                    offset: const Offset(0, 6),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFFFFFFF).withOpacity(0.15),
                                    blurRadius: 0,
                                    offset: const Offset(0, 1),
                                    spreadRadius: 0,
                                    blurStyle: BlurStyle.inner,
                                  ),
                                ],
                              ),
                              child: CupertinoButton(
                                onPressed: _openAppStoreSubscriptions,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                borderRadius: BorderRadius.circular(20),
                                child: const Text(
                                  'Manage in App Store',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Close button (ghost)
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9B8A7A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B7563),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3C342A),
          ),
        ),
      ],
    );
  }
}
