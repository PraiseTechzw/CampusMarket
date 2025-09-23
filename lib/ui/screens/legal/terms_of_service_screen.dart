/// @Branch: Terms of Service Screen
///
/// Legal terms and conditions for Campus Market
/// Professional legal document with proper formatting
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
                    'Terms of Service',
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
                    'Campus Market - Zimbabwe\'s Premier Student Marketplace',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Terms Content
            _buildSection(
              theme,
              '1. Acceptance of Terms',
              'By accessing and using Campus Market, you accept and agree to be bound by the terms and provisions of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),

            _buildSection(
              theme,
              '2. Use License',
              'Permission is granted to temporarily download one copy of Campus Market for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n• Modify or copy the materials\n• Use the materials for any commercial purpose or for any public display\n• Attempt to reverse engineer any software contained on the website\n• Remove any copyright or other proprietary notations from the materials',
            ),

            _buildSection(
              theme,
              '3. Student Verification',
              'Users must be verified students from recognized Zimbabwean universities. University email addresses (.ac.zw) are automatically verified. Non-university email addresses require manual admin verification before users can sell items on the platform.',
            ),

            _buildSection(
              theme,
              '4. User Responsibilities',
              'As a user of Campus Market, you agree to:\n\n• Provide accurate and truthful information\n• Use the platform only for lawful purposes\n• Respect other users and maintain a professional environment\n• Not engage in fraudulent, misleading, or deceptive practices\n• Comply with all applicable laws and regulations',
            ),

            _buildSection(
              theme,
              '5. Prohibited Uses',
              'You may not use our service:\n\n• For any unlawful purpose or to solicit others to perform unlawful acts\n• To violate any international, federal, provincial, or state regulations, rules, laws, or local ordinances\n• To infringe upon or violate our intellectual property rights or the intellectual property rights of others\n• To harass, abuse, insult, harm, defame, slander, disparage, intimidate, or discriminate\n• To submit false or misleading information\n• To upload or transmit viruses or any other type of malicious code',
            ),

            _buildSection(
              theme,
              '6. Content and Intellectual Property',
              'All content, including but not limited to text, graphics, logos, images, and software, is the property of Campus Market or its content suppliers and is protected by copyright and other intellectual property laws. You may not reproduce, distribute, or create derivative works without express written permission.',
            ),

            _buildSection(
              theme,
              '7. Privacy and Data Protection',
              'Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the service, to understand our practices. We are committed to protecting your personal information in accordance with applicable data protection laws.',
            ),

            _buildSection(
              theme,
              '8. Disclaimers',
              'The information on this platform is provided on an "as is" basis. To the fullest extent permitted by law, Campus Market excludes all representations, warranties, conditions and terms relating to our website and the use of this website.',
            ),

            _buildSection(
              theme,
              '9. Limitation of Liability',
              'In no event shall Campus Market, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your use of the service.',
            ),

            _buildSection(
              theme,
              '10. Termination',
              'We may terminate or suspend your account and bar access to the service immediately, without prior notice or liability, under our sole discretion, for any reason whatsoever and without limitation, including but not limited to a breach of the Terms.',
            ),

            _buildSection(
              theme,
              '11. Governing Law',
              'These Terms shall be interpreted and governed by the laws of Zimbabwe. Any disputes relating to these terms will be subject to the exclusive jurisdiction of the courts of Zimbabwe.',
            ),

            _buildSection(
              theme,
              '12. Changes to Terms',
              'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days notice prior to any new terms taking effect.',
            ),

            _buildSection(
              theme,
              '13. Contact Information',
              'If you have any questions about these Terms of Service, please contact us at:\n\nEmail: legal@campusmarket.co.zw\nPhone: +263 786 223 289\nAddress: Harare, Zimbabwe',
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
              child: Text(
                'By using Campus Market, you acknowledge that you have read and understood these Terms of Service and agree to be bound by them.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
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
