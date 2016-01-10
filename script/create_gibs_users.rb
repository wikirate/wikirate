require File.expand_path('../../config/environment', __FILE__)
Card::Auth.as_bot
Card::Mailer.perform_deliveries = false
CSV.foreach('script/gibs_users.csv', encoding: 'windows-1251:utf-8',
                                     headers: true,
                                     header_converters: :symbol) do |row|
  exist_email = Card.search(content: row[:email], left: { right: '*account' },
                            right: '*email')
  username = "#{row[:first_name]} #{row[:surname]}"
  if !(Card.exists?(username) || exist_email.any?)
    args = {
      name: username,
      type_id: Card::UserID,
      '+*account' => {
        '+*email' => row[:email],
        '+*password' => row[:password]
      }
    }
    puts "account to be created: #{args}"
    Card.create! args
    puts "activating #{username}"
    status_card = Card["#{username}+*account+*status"]
    status_card.update_attributes! content: 'active', silent_change: true
  else
    puts "creating existing account #{row}".red
  end
end
Card::Mailer.perform_deliveries = true
