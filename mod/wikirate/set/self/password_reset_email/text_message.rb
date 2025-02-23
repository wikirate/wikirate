include_set Abstract::CodeContent
include_set Abstract::VirtualSet

format do
  view :raw, unknown: true do
    <<~MESSAGE
      Someone, we hope you, asked to reset your password.

      Reset your password: {{_|reset_password_url}}

      (Link will remain valid for {{_|reset_password_days}} days.)
    MESSAGE
  end
end
