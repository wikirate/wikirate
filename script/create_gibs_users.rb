require File.expand_path('../../config/environment', __FILE__)
Card::Auth.as_bot
Card::Mailer.perform_deliveries = false
CSV.foreach('script/gibs_users.csv', encoding: 'windows-1251:utf-8',
                                     headers: true,
                                     header_converters: :symbol) do |row|
  unless Card.exists? row[:name]
    args = {
      name: row[:name],
      type_id: Card::UserID,
      '+*account' => {
        '+*email' => row[:email],
        '+*password' => row[:password]
      }
    }
    puts "account to be created: #{args}"
    Card.create! args
    puts "activating #{row[:name]}"
    status_card = Card["#{row[:name]}+*account+*status"]
    status_card.update_attributes! content: 'active', silent_change: true
  end
end
Card::Mailer.perform_deliveries = true
