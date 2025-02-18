include_set Abstract::CodeContent
include_set Abstract::VirtualSet

format do
  view :raw, unknown: true do
    <<~MESSAGE
      Thank you for signing up with Wikirate!

      Please follow the link below to verify this email address and activate your account.

      {{_|verify_url}}

      (Link will remain valid for {{_|verify_days}} days.)
    MESSAGE
  end
end
