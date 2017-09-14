# -*- encoding : utf-8 -*-

class EmailUpdate < Card::Migration
  def up
    merge_cards [
                  "welcome_email+*html_message",
                  "verification_email+*html_message",
                  "email header",
                  "email footer"
                ]
  end
end
