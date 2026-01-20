# frozen_string_literal: true

module Views
  module Pages
    class Privacy < Views::Base
      def view_template
        div do
          h1 { "Privacy Policy" }

          p do
            strong { "Last Updated:" }
            plain(" January 20, 2026")
          end

          div do
            section do
              h2 { "1. Introduction" }
              p do
                <<~TEXT
                  Welcome to Flash ("we," "our," or "us"). This Privacy Policy
                  explains how we collect, use, disclose, and safeguard your
                  information when you use our flashcard study application (the
                  "Service"). Please read this privacy policy carefully. If you
                  do not agree with the terms of this privacy policy, please do
                  not access the Service.
                TEXT
              end
            end

            section do
              h2 { "2. Information We Collect" }

              h3 { "2.1 Personal Information" }
              p { "When you create an account, we collect:" }
              ul do
                li do
                  strong { "Email Address:" }
                  plain(" Used for account creation, authentication, and communication")
                end
                li do
                  strong { "Password:" }
                  plain(" Stored in hashed form (using bcrypt) for account security")
                end
              end

              h3 { "2.2 Study Content and Progress" }
              p { "To provide our flashcard study service, we store:" }
              ul do
                li do
                  strong { "Flashcard Decks:" }
                  plain(" The decks you create or upload, including deck names")
                end
                li do
                  strong { "Flashcard Content:" }
                  plain(<<~TEXT)
                     The front (question) and back (answer) of each flashcard,
                    along with categories
                  TEXT
                end
                li do
                  strong { "Study Statistics:" }
                  plain(" Your study progress including:")
                  ul do
                    li { "Number of correct and incorrect answers" }
                    li { "Current correct answer streak" }
                    li { "View count for each card" }
                    li do
                      <<~TEXT
                        Historical wrong answers (used to generate better quiz
                        options)
                      TEXT
                    end
                    li { "Card status (pending, active, or done)" }
                  end
                end
              end

              h3 { "2.3 Subscription Information" }
              p { "If you subscribe to our paid service, we store:" }
              ul do
                li { "Subscription status (active, canceled, past due)" }
                li { "Current billing period dates" }
                li { "Cancellation date (if applicable)" }
                li { "Plan name" }
                li { "Subscription ID from our payment processor" }
              end

              h3 { "2.4 Usage Data" }
              ul do
                li do
                  strong { "Cookies and Session Data:" }
                  plain(" We use cookies to maintain your login session")
                end
                li do
                  strong { "Server Logs:" }
                  plain(<<~TEXT)
                     Standard web server logs (IP addresses, browser type, pages
                    visited) are collected automatically
                  TEXT
                end
              end

              h3 { "2.5 Uploaded Files" }
              p do
                <<~TEXT
                  When you upload CSV files to import flashcard decks, these
                  files are processed on our servers and then deleted. Only the
                  extracted flashcard data is retained.
                TEXT
              end
            end

            section do
              h2 { "3. How We Use Your Information" }
              p { "We use the information we collect to:" }
              ul do
                li { "Provide, operate, and maintain the Service" }
                li { "Authenticate your account and maintain your session" }
                li do
                  <<~TEXT
                    Store and manage your flashcard decks and study progress
                  TEXT
                end
                li { "Implement our spaced repetition study algorithm" }
                li { "Process and manage your subscription" }
                li { "Send important service-related communications" }
                li { "Improve and optimize the Service" }
                li { "Detect and prevent fraud or abuse" }
              end
            end

            section do
              h2 { "4. Third-Party Services" }

              h3 { "4.1 Payment Processing" }
              p do
                plain("We use ")
                strong { "Creem" }
                plain(<<~TEXT)
                   (creem.io) to process subscription payments. When you
                  subscribe, we share your email address and subscription details
                  with Creem. Please review Creem's privacy policy at their
                  website for information about how they handle your payment
                  information.
                TEXT
              end

              h3 { "4.2 Hosting and Infrastructure" }
              p do
                <<~TEXT
                  Our Service is hosted on third-party servers. These providers
                  have access to your data only for the purpose of providing
                  hosting services and are obligated to maintain confidentiality.
                TEXT
              end

              h3 { "4.3 No Analytics or Tracking" }
              p do
                <<~TEXT
                  We do not use third-party analytics services, advertising
                  networks, or tracking tools. We do not sell your data to third
                  parties.
                TEXT
              end
            end

            section do
              h2 { "5. Data Security" }
              p do
                "We implement security measures to protect your information:"
              end
              ul do
                li do
                  strong { "Encryption:" }
                  plain(<<~TEXT)
                     All data transmitted to and from our Service uses SSL/HTTPS
                    encryption
                  TEXT
                end
                li do
                  strong { "Password Security:" }
                  plain(" Passwords are hashed using bcrypt and never stored in plain text")
                end
                li do
                  strong { "Secure Sessions:" }
                  plain(" Session cookies are protected with CSRF tokens")
                end
                li do
                  strong { "Log Filtering:" }
                  plain(<<~TEXT)
                     Sensitive information (passwords, emails, tokens, API keys)
                    is automatically filtered from application logs
                  TEXT
                end
                li do
                  strong { "Access Controls:" }
                  plain(" You can only access your own flashcard decks and study data")
                end
              end
              p do
                <<~TEXT
                  However, no method of transmission over the Internet or
                  electronic storage is 100% secure. While we strive to use
                  commercially acceptable means to protect your information, we
                  cannot guarantee absolute security.
                TEXT
              end
            end

            section do
              h2 { "6. Your Rights and Choices" }

              h3 { "6.1 Access and Update" }
              p do
                <<~TEXT
                  You can access and update your account information at any time
                  by logging into your account.
                TEXT
              end

              h3 { "6.2 Account Deletion" }
              p do
                <<~TEXT
                  You can delete your account at any time through your account
                  settings. When you delete your account:
                TEXT
              end
              ul do
                li do
                  <<~TEXT
                    Your account information, flashcard decks, and study progress
                    will be permanently deleted
                  TEXT
                end
                li { "This action cannot be undone" }
                li do
                  <<~TEXT
                    If you have an active subscription, you should cancel it
                    before deleting your account
                  TEXT
                end
              end

              h3 { "6.3 Data Portability" }
              p do
                <<~TEXT
                  You can export your flashcard decks at any time. Contact us if
                  you need assistance accessing your data.
                TEXT
              end

              h3 { "6.4 Cookies" }
              p do
                <<~TEXT
                  You can instruct your browser to refuse all cookies or to
                  indicate when a cookie is being sent. However, if you do not
                  accept cookies, you may not be able to use the Service.
                TEXT
              end
            end

            section do
              h2 { "7. Data Retention" }
              p do
                <<~TEXT
                  We retain your personal information for as long as your account
                  is active or as needed to provide you the Service. When you
                  delete your account, we permanently delete your data. We may
                  retain certain information as required by law or for legitimate
                  business purposes.
                TEXT
              end
            end

            section do
              h2 { "8. Children's Privacy" }
              p do
                <<~TEXT
                  Our Service is not directed to individuals under the age of 13.
                  We do not knowingly collect personal information from children
                  under 13. If you are a parent or guardian and believe your
                  child has provided us with personal information, please contact
                  us so we can delete such information.
                TEXT
              end
            end

            section do
              h2 { "9. International Data Transfers" }
              p do
                <<~TEXT
                  Your information may be transferred to and maintained on
                  servers located outside of your state, province, country, or
                  other governmental jurisdiction where data protection laws may
                  differ. By using the Service, you consent to such transfers.
                TEXT
              end
            end

            section do
              h2 { "10. Changes to This Privacy Policy" }
              p do
                <<~TEXT
                  We may update this Privacy Policy from time to time. We will
                  notify you of any changes by updating the "Last Updated" date
                  at the top of this policy. You are advised to review this
                  Privacy Policy periodically for any changes. Changes to this
                  Privacy Policy are effective when they are posted on this
                  page."
                TEXT
              end
            end

            section do
              h2 { "11. Contact Us" }
              p do
                <<~TEXT
                  If you have any questions about this Privacy Policy or our data
                  practices, please contact us at:
                TEXT
              end
              ul do
                li do
                  strong { "Email:" }
                  plain(" ")
                  mail_to("support+flash@boon.gl")
                end
              end
            end

            section do
              h2 { "12. Your Privacy Rights" }

              h3 { "12.1 GDPR (European Users)" }
              p do
                <<~TEXT
                  If you are located in the European Economic Area (EEA), you
                  have certain rights under the General Data Protection
                  Regulation (GDPR):
                TEXT
              end
              ul do
                li do
                  strong { "Right to Access:" }
                  plain(" You can request access to your personal data")
                end
                li do
                  strong { "Right to Rectification:" }
                  plain(" You can update or correct your personal data")
                end
                li do
                  strong { "Right to Erasure:" }
                  plain(" You can request deletion of your personal data")
                end
                li do
                  strong { "Right to Restrict Processing:" }
                  plain(" You can request that we limit how we use your data")
                end
                li do
                  strong { "Right to Data Portability:" }
                  plain(<<~TEXT)
                    You can request a copy of your data in a structured format
                  TEXT
                end
                li do
                  strong { "Right to Object:" }
                  plain(" You can object to our processing of your data")
                end
                li do
                  strong { "Right to Withdraw Consent:" }
                  plain(" You can withdraw your consent at any time")
                end
              end

              h3 { "12.2 CCPA (California Users)" }
              p do
                <<~TEXT
                  If you are a California resident, you have rights under the
                  California Consumer Privacy Act (CCPA):
                TEXT
              end
              ul do
                li do
                  strong { "Right to Know:" }
                  plain(<<~TEXT)
                     You can request information about the personal data we
                    collect and how we use it
                  TEXT
                end
                li do
                  strong { "Right to Delete:" }
                  plain(" You can request deletion of your personal data")
                end
                li do
                  strong { "Right to Opt-Out:" }
                  plain(" We do not sell your personal information")
                end
                li do
                  strong { "Right to Non-Discrimination:" }
                  plain(<<~TEXT)
                     We will not discriminate against you for exercising your
                    privacy rights
                  TEXT
                end
              end

              p do
                plain("To exercise any of these rights, please contact us at ")
                mail_to("support+flash@boon.gl")
                plain(".")
              end
            end
          end
        end
      end
    end
  end
end
