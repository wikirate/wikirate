include_set Abstract::CodeContent
include_set Abstract::VirtualSet

format do
  view :raw, unknown: true do
    <<~MESSAGE
      We're glad that you're here.

      Activate your account: {{_|verify_url}}

      (Link will remain valid for {{_|verify_days}} days.)
    MESSAGE
  end
end
