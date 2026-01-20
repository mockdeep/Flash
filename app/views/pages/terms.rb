# frozen_string_literal: true

module Views
  module Pages
    class Terms < Views::Base
      def view_template
        div do
          h1 { "Terms of Service" }

          p do
            strong { "Last Updated:" }
            plain(" January 20, 2026")
          end

          div do
            section do
              h2 { "1. Acceptance of Terms" }
              p do
                <<~TEXT
                  Welcome to Flash. By accessing or using our flashcard study
                  application (the "Service"), you agree to be bound by these
                  Terms of Service ("Terms"). If you do not agree to these
                  Terms, please do not use the Service.
                TEXT
              end
              p do
                <<~TEXT
                  We reserve the right to modify these Terms at any time. Changes
                  will be effective when posted. Your continued use of the Service
                  after changes are posted constitutes your acceptance of the
                  modified Terms.
                TEXT
              end
            end

            section do
              h2 { "2. Description of Service" }
              p do
                <<~TEXT
                  Flash is a web-based flashcard study application that allows you
                  to create, upload, and study flashcard decks using a spaced
                  repetition algorithm. The Service helps you learn and retain
                  information through systematic review and testing.
                TEXT
              end
            end

            section do
              h2 { "3. Account Registration and Security" }

              h3 { "3.1 Account Creation" }
              p { "To use the Service, you must:" }
              ul do
                li do
                  <<~TEXT
                    Create an account by providing a valid email address and
                    password
                  TEXT
                end
                li { "Be at least 13 years of age" }
                li { "Provide accurate and complete information" }
                li do
                  <<~TEXT
                    Maintain and update your information to keep it accurate
                  TEXT
                end
              end

              h3 { "3.2 Account Security" }
              p { "You are responsible for:" }
              ul do
                li { "Maintaining the confidentiality of your password" }
                li { "All activities that occur under your account" }
                li do
                  <<~TEXT
                    Notifying us immediately of any unauthorized use of your
                    account
                  TEXT
                end
              end

              h3 { "3.3 Account Restrictions" }
              p { "You may not:" }
              ul do
                li { "Share your account with others" }
                li { "Create multiple accounts for the same person" }
                li { "Use another person's account without permission" }
                li { "Create accounts through automated means" }
              end
            end

            section do
              h2 { "4. User Content" }

              h3 { "4.1 Your Content" }
              p do
                <<~TEXT
                  You retain all rights to the flashcard content you create or
                  upload ("Your Content"). By uploading content to the Service,
                  you grant us a limited license to store, display, and process
                  Your Content solely for the purpose of providing the Service
                  to you.
                TEXT
              end

              h3 { "4.2 Content Restrictions" }
              p { "You agree not to upload or create content that:" }
              ul do
                li { "Violates any law or regulation" }
                li { "Infringes on intellectual property rights of others" }
                li { "Contains malware, viruses, or harmful code" }
                li { "Is harassing, abusive, threatening, or hateful" }
                li { "Contains spam or unsolicited promotional material" }
                li { "Violates the privacy rights of others" }
              end

              h3 { "4.3 Content Responsibility" }
              p do
                <<~TEXT
                  You are solely responsible for Your Content and the
                  consequences of uploading or publishing it. We do not
                  endorse, support, represent, or guarantee the accuracy,
                  completeness, or reliability of any user content.
                TEXT
              end

              h3 { "4.4 Content Removal" }
              p do
                <<~TEXT
                  We reserve the right to remove any content that violates these
                  Terms or is otherwise objectionable, without prior notice.
                TEXT
              end
            end

            section do
              h2 { "5. Subscriptions and Payments" }

              h3 { "5.1 Subscription Plans" }
              p do
                <<~TEXT
                  Certain features of the Service may require a paid
                  subscription. Subscription plans, features, and pricing are
                  described on our website and may change from time to time.
                TEXT
              end

              h3 { "5.2 Billing" }
              ul do
                li do
                  <<~TEXT
                    Subscriptions are billed in advance on a recurring basis
                    (monthly, annually, or as specified)
                  TEXT
                end
                li do
                  <<~TEXT
                    Payment is processed through our third-party payment
                    processor, Creem
                  TEXT
                end
                li do
                  <<~TEXT
                    You authorize us to charge your payment method for all
                    subscription fees
                  TEXT
                end
                li do
                  "If a payment fails, we may suspend or terminate your subscription"
                end
              end

              h3 { "5.3 Cancellation" }
              ul do
                li do
                  <<~TEXT
                    You may cancel your subscription at any time through your
                    account settings
                  TEXT
                end
                li do
                  <<~TEXT
                    Cancellation takes effect at the end of your current billing
                    period
                  TEXT
                end
                li do
                  <<~TEXT
                    You will retain access to paid features until the end of your
                    billing period
                  TEXT
                end
                li do
                  "No refunds or credits will be provided for partial billing periods"
                end
              end

              h3 { "5.4 Price Changes" }
              p do
                <<~TEXT
                  We may change subscription prices at any time. Price changes
                  will take effect at the start of your next billing period
                  after we notify you. If you do not agree to a price change,
                  you may cancel your subscription.
                TEXT
              end

              h3 { "5.5 Refund Policy" }
              p do
                <<~TEXT
                  All subscription fees are non-refundable except as required by
                  law or as explicitly stated in these Terms. We do not provide
                  refunds for partial months or years, or for unused portions of
                  your subscription.
                TEXT
              end
            end

            section do
              h2 { "6. Acceptable Use" }

              p { "You agree not to:" }
              ul do
                li do
                  <<~TEXT
                    Use the Service for any illegal purpose or in violation of
                    any laws
                  TEXT
                end
                li do
                  <<~TEXT
                    Attempt to gain unauthorized access to the Service, other
                    accounts, or computer systems
                  TEXT
                end
                li do
                  <<~TEXT
                    Interfere with or disrupt the Service or servers or networks
                    connected to the Service
                  TEXT
                end
                li do
                  "Use automated scripts, bots, or scrapers to access the Service"
                end
                li do
                  "Reverse engineer, decompile, or disassemble any portion of the Service"
                end
                li do
                  "Remove, circumvent, or disable any security features or access controls"
                end
                li { "Transmit any viruses, malware, or other harmful code" }
                li do
                  "Impersonate any person or entity or misrepresent your affiliation"
                end
                li { "Collect or harvest information about other users" }
                li { "Use the Service to send spam or unsolicited messages" }
              end
            end

            section do
              h2 { "7. Intellectual Property" }

              h3 { "7.1 Our Rights" }
              p do
                <<~TEXT
                  The Service, including its design, features, functionality,
                  text, graphics, logos, and software, is owned by Flash and is
                  protected by copyright, trademark, and other intellectual
                  property laws. You may not copy, modify, distribute, sell, or
                  lease any part of the Service.
                TEXT
              end

              h3 { "7.2 Limited License" }
              p do
                <<~TEXT
                  We grant you a limited, non-exclusive, non-transferable,
                  revocable license to access and use the Service for your
                  personal, non-commercial use, subject to these Terms.
                TEXT
              end

              h3 { "7.3 Trademarks" }
              p do
                <<~TEXT
                  "Flash" and any associated logos are trademarks or registered
                  trademarks. You may not use these marks without our prior
                  written permission.
                TEXT
              end
            end

            section do
              h2 { "8. Disclaimers and Limitations of Liability" }

              h3 { "8.1 Service \"As Is\"" }
              p do
                <<~TEXT
                  THE SERVICE IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT
                  WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING
                  BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY,
                  FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. WE DO
                  NOT WARRANT THAT THE SERVICE WILL BE UNINTERRUPTED, SECURE, OR
                  ERROR-FREE.
                TEXT
              end

              h3 { "8.2 Educational Tool" }
              p do
                <<~TEXT
                  The Service is an educational tool. We do not guarantee any
                  learning outcomes or results from using the Service. You are
                  solely responsible for your educational goals and
                  achievements.
                TEXT
              end

              h3 { "8.3 Content Accuracy" }
              p do
                <<~TEXT
                  We are not responsible for the accuracy, completeness, or
                  usefulness of user-generated content. You should verify all
                  information independently.
                TEXT
              end

              h3 { "8.4 Limitation of Liability" }
              p do
                <<~TEXT
                  TO THE MAXIMUM EXTENT PERMITTED BY LAW, FLASH SHALL NOT BE LIABLE
                  FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE
                  DAMAGES, OR ANY LOSS OF PROFITS OR REVENUES, WHETHER INCURRED
                  DIRECTLY OR INDIRECTLY, OR ANY LOSS OF DATA, USE, GOODWILL, OR
                  OTHER INTANGIBLE LOSSES, RESULTING FROM:
                TEXT
              end
              ul do
                li { "Your use or inability to use the Service" }
                li do
                  <<~TEXT
                    Any unauthorized access to or use of our servers or any
                    personal information stored therein
                  TEXT
                end
                li { "Any interruption or cessation of the Service" }
                li do
                  <<~TEXT
                    Any bugs, viruses, or other harmful code transmitted through
                    the Service
                  TEXT
                end
                li do
                  <<~TEXT
                    Any errors or omissions in any content or for any loss or
                    damage incurred as a result of your use of any content
                  TEXT
                end
              end
              p do
                <<~TEXT
                  IN NO EVENT SHALL OUR TOTAL LIABILITY TO YOU FOR ALL DAMAGES,
                  LOSSES, AND CAUSES OF ACTION EXCEED THE AMOUNT YOU HAVE PAID US
                  IN THE TWELVE (12) MONTHS PRIOR TO THE CLAIM, OR ONE HUNDRED
                  DOLLARS ($100), WHICHEVER IS GREATER.
                TEXT
              end
            end

            section do
              h2 { "9. Indemnification" }
              p do
                <<~TEXT
                  You agree to indemnify, defend, and hold harmless Flash, its
                  officers, directors, employees, agents, and affiliates from and
                  against any claims, liabilities, damages, losses, and expenses,
                  including reasonable attorneys' fees, arising out of or in any
                  way connected with:
                TEXT
              end
              ul do
                li { "Your access to or use of the Service" }
                li { "Your violation of these Terms" }
                li do
                  <<~TEXT
                    Your violation of any rights of another party, including
                    intellectual property rights
                  TEXT
                end
                li { "Your Content" }
              end
            end

            section do
              h2 { "10. Termination" }

              h3 { "10.1 Termination by You" }
              p do
                <<~TEXT
                  You may terminate your account at any time by deleting your
                  account through your account settings. Upon deletion, all your
                  data will be permanently removed.
                TEXT
              end

              h3 { "10.2 Termination by Us" }
              p do
                <<~TEXT
                  We may suspend or terminate your account and access to the
                  Service at any time, with or without cause, with or without
                  notice. Reasons for termination may include:
                TEXT
              end
              ul do
                li { "Violation of these Terms" }
                li { "Fraudulent or illegal activity" }
                li { "Extended periods of inactivity" }
                li { "Non-payment of subscription fees" }
              end

              h3 { "10.3 Effect of Termination" }
              p do
                <<~TEXT
                  Upon termination, your right to use the Service will immediately
                  cease. All provisions of these Terms that by their nature should
                  survive termination shall survive, including ownership
                  provisions, warranty disclaimers, indemnity, and limitations of
                  liability.
                TEXT
              end
            end

            section do
              h2 { "11. Data Backup and Loss" }
              p do
                <<~TEXT
                  While we make reasonable efforts to ensure the availability and
                  integrity of your data, we are not responsible for any loss of
                  data. You are solely responsible for maintaining backups of Your
                  Content. We recommend regularly exporting your flashcard decks.
                TEXT
              end
            end

            section do
              h2 { "12. Third-Party Links and Services" }
              p do
                <<~TEXT
                  The Service may contain links to third-party websites or services
                  that are not owned or controlled by Flash. We have no control
                  over and assume no responsibility for the content, privacy
                  policies, or practices of any third-party websites or services.
                  You acknowledge and agree that we shall not be liable for any
                  damage or loss caused by your use of any third-party websites or
                  services.
                TEXT
              end
            end

            section do
              h2 { "13. Governing Law and Dispute Resolution" }

              h3 { "13.1 Governing Law" }
              p do
                <<~TEXT
                  These Terms shall be governed by and construed in accordance with
                  the laws of the United States, without regard to its conflict of
                  law provisions.
                TEXT
              end

              h3 { "13.2 Disputes" }
              p do
                <<~TEXT
                  Any dispute arising from these Terms or the Service shall be
                  resolved through good faith negotiations. If negotiations fail,
                  disputes shall be resolved through binding arbitration in
                  accordance with the rules of the American Arbitration
                  Association.
                TEXT
              end
            end

            section do
              h2 { "14. Changes to the Service" }
              p do
                <<~TEXT
                  We reserve the right to modify, suspend, or discontinue the
                  Service (or any part thereof) at any time, with or without
                  notice. We shall not be liable to you or any third party for any
                  modification, suspension, or discontinuance of the Service.
                TEXT
              end
            end

            section do
              h2 { "15. Entire Agreement" }
              p do
                <<~TEXT
                  These Terms, together with our Privacy Policy, constitute the
                  entire agreement between you and Flash regarding the Service and
                  supersede all prior agreements and understandings.
                TEXT
              end
            end

            section do
              h2 { "16. Severability" }
              p do
                <<~TEXT
                  If any provision of these Terms is found to be invalid or
                  unenforceable, the remaining provisions shall remain in full
                  force and effect.
                TEXT
              end
            end

            section do
              h2 { "17. Waiver" }
              p do
                <<~TEXT
                  No waiver of any term of these Terms shall be deemed a further or
                  continuing waiver of such term or any other term, and our failure
                  to assert any right or provision under these Terms shall not
                  constitute a waiver of such right or provision.
                TEXT
              end
            end

            section do
              h2 { "18. Contact Information" }
              p do
                "If you have any questions about these Terms, please contact us at:"
              end
              ul do
                li do
                  strong { "Email: " }
                  mail_to("support+flash@boon.gl")
                end
              end
            end

            section do
              h2 { "19. Acknowledgment" }
              p do
                <<~TEXT
                  BY USING THE SERVICE, YOU ACKNOWLEDGE THAT YOU HAVE READ THESE
                  TERMS OF SERVICE AND AGREE TO BE BOUND BY THEM.
                TEXT
              end
            end
          end
        end
      end
    end
  end
end
