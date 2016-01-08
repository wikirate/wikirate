require File.expand_path('../../config/environment',  __FILE__)

CSV.foreach('script/gist_users.csv', encoding: 'windows-1251:utf-8',
                                     headers: true,
                                     header_converters: :symbol) do |row|
  Card::Auth.current_id = Card::AnonymousID
  unless Card.exists? row[:name]
    args = {
      name: row[:name],
      type_id: Card::SignupID,
      '+*account' => {
        '+*email' => 'wikirate@mailinator.com',
        '+*password' => row[:password]
      }
    }
    puts "account to be created: #{args}"
    signup = Card.create! args
    Card::Auth.as_bot
    puts "activating #{row[:name]}"
    signup.activate_account
    puts "update email of #{row[:name]} to #{row[:email]}"
    email_card = Card["#{row[:name]}+*account+*email"]
    email_card.update_attributes! content: row[:email], silent_change: true
  end
end
