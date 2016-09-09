# -*- encoding : utf-8 -*-

class ImportFixedSignupMessage < Card::Migration
  def up
    import_cards 'fixed_signup_message.json'
  end
end
