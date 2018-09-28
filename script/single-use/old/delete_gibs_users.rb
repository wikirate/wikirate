require File.expand_path("../../config/environment", __FILE__)
Card::Auth.as_bot
Card::Mailer.perform_deliveries = false
CSV.foreach("script/gibs_users.csv", encoding: "windows-1251:utf-8",
                                     headers: true,
                                     header_converters: :symbol) do |row|
  exist_email = Card.search(content: row[:email], left: { right: "*account" },
                            right: "*email")
  if exist_email.any?
    user_to_be_deleted = exist_email[0].left.left
    puts "deleting #{user_to_be_deleted.name}"
    user_to_be_deleted.delete!
  end
end
Card::Mailer.perform_deliveries = true
