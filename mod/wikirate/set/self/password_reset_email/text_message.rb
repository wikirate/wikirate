include_set Abstract::CodeContent
include_set Abstract::VirtualSet

format do
  view :raw, unknown: true do
    <<~MESSAGE
      Password reset for Wikirate

      Someone – you, we hope – asked to reset your password.  Please use the following
      link to update your account details:
      
      {{_|reset_password_url}}  
      
      Link will remain valid for {{_|reset_password_days}} days.
    MESSAGE
  end
end
