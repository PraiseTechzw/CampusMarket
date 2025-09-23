/// @Branch: Privacy Policy Screen
///
/// Privacy policy and data protection information for Campus Market
/// Comprehensive privacy policy with GDPR compliance
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/sign-in');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Effective Date: September 2025',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Campus Market - Your Privacy Matters',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Privacy Policy Content
            _buildSection(
              theme,
              '1. Information We Collect',
              'We collect information you provide directly to us, such as when you create an account, make a purchase, or contact us for support. This may include:\n\n• Personal Information: Name, email address, phone number, university affiliation\n• Academic Information: Student ID, university details, verification status\n• Transaction Information: Purchase history, payment details, shipping information\n• Communication Data: Messages, feedback, and support requests\n• Usage Data: How you interact with our platform, pages visited, features used',
            ),

            _buildSection(
              theme,
              '2. How We Use Your Information',
              'We use the information we collect to:\n\n• Provide, maintain, and improve our services\n• Process transactions and send related information\n• Send technical notices, updates, security alerts, and support messages\n• Respond to your comments, questions, and requests\n• Verify student status and university affiliation\n• Monitor and analyze trends, usage, and activities\n• Personalize and improve your experience\n• Detect, investigate, and prevent fraudulent transactions',
            ),

            _buildSection(
              theme,
              '3. Information Sharing and Disclosure',
              'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except in the following circumstances:\n\n• With your explicit consent\n• To comply with legal obligations or court orders\n• To protect our rights, property, or safety, or that of our users\n• In connection with a merger, acquisition, or sale of assets\n• With service providers who assist us in operating our platform (under strict confidentiality agreements)\n• With university administrators for verification purposes',
            ),

            _buildSection(
              theme,
              '4. Data Security',
              'We implement appropriate technical and organizational security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. These measures include:\n\n• Encryption of data in transit and at rest\n• Regular security assessments and updates\n• Access controls and authentication systems\n• Secure data centers with physical security measures\n• Regular staff training on data protection\n• Incident response procedures',
            ),

            _buildSection(
              theme,
              '5. Data Retention',
              'We retain your personal information only for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law. Specifically:\n\n• Account information: Until you delete your account\n• Transaction data: 7 years for tax and legal compliance\n• Communication records: 3 years for customer service purposes\n• Verification data: Until account closure or verification revocation',
            ),

            _buildSection(
              theme,
              '6. Your Rights and Choices',
              'You have the following rights regarding your personal information:\n\n• Access: Request a copy of the personal information we hold about you\n• Rectification: Correct inaccurate or incomplete information\n• Erasure: Request deletion of your personal information\n• Portability: Receive your data in a structured, machine-readable format\n• Restriction: Limit how we process your information\n• Objection: Object to certain types of processing\n• Withdraw Consent: Withdraw consent for data processing where applicable',
            ),

            _buildSection(
              theme,
              '7. Cookies and Tracking Technologies',
              'We use cookies and similar tracking technologies to enhance your experience on our platform. These technologies help us:\n\n• Remember your preferences and settings\n• Analyze how you use our platform\n• Provide personalized content and advertisements\n• Improve our services and user experience\n\nYou can control cookie settings through your browser preferences.',
            ),

            _buildSection(
              theme,
              '8. Third-Party Services',
              'Our platform may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to read their privacy policies before providing any personal information.',
            ),

            _buildSection(
              theme,
              '9. International Data Transfers',
              'Your information may be transferred to and processed in countries other than your own. We ensure that such transfers comply with applicable data protection laws and implement appropriate safeguards to protect your information.',
            ),

            _buildSection(
              theme,
              '10. Children\'s Privacy',
              'Our services are not intended for children under 16 years of age. We do not knowingly collect personal information from children under 16. If we become aware that we have collected personal information from a child under 16, we will take steps to delete such information.',
            ),

            _buildSection(
              theme,
              '11. Changes to This Privacy Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Effective Date" at the top. We encourage you to review this Privacy Policy periodically for any changes.',
            ),

            _buildSection(
              theme,
              '12. Contact Us',
              'If you have any questions about this Privacy Policy or our data practices, please contact us at:\n\nEmail: privacy@campusmarket.co.zw\nPhone: +263 786 223 289\nAddress: Harare, Zimbabwe\n\nData Protection Officer: dpo@campusmarket.co.zw',
            ),

            const SizedBox(height: AppSpacing.xl),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Your privacy is important to us. We are committed to protecting your personal information and being transparent about our data practices.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'This Privacy Policy is effective as of September 2025 and will remain in effect except with respect to any changes in its provisions in the future.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
