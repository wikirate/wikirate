# -*- encoding : utf-8 -*-

class MigrateLogoToImage < Card::Migration
  def up
    # delete cards with logo and image
    # change name from +logo to +image
    # update some structure cards

    company_image_structure_name = "Company+image+*type plus right+*structure"
    puts "delete #{company_image_structure_name}"
    if (company_image_structure_card = Card[company_image_structure_name])
      company_image_structure_card.delete
    end
    puts "delete #{company_image_structure_name}"
    user_image_structure_name = "User+image+*type plus right+*structure"
    if (user_image_structure_card = Card[user_image_structure_name])
      user_image_structure_card.delete
    end
    puts "delete cards with logo and image"
    cards_with_both = Card.search right_plus: %w(and logo image)
    puts "\tfound #{cards_with_both.size}"
    cards_with_both.each do |c|
      card_name = "#{c.name}+logo"
      puts "\tdeleting #{card_name}"
      Card[card_name].delete
    end
    puts "renaming card+logo to card+image and update the type id"
    logo_cards = Card.search right_plus: "logo"
    puts "\tfound #{logo_cards.size}"
    logo_cards.each do |c|
      puts "\trenaming #{c.name}+logo to #{c.name}+image"
      card = Card["#{c.name}+logo"]
      card.name = "#{c.name}+image"
      card.save!
      card.type_id = Card::ImageID
      card.save!
    end
    puts 'updating html card content with \'+logo\' to \'+image\''
    cards_with_logo = Card.search content: ["match", '\\+logo'],
                                  type_id: Card::HtmlID
    puts "\tfound #{cards_with_logo.size}"
    cards_with_logo.each do |c|
      content = c.content
      content.gsub!("+logo", "+image")
      c.content = content
      puts "\tupdating #{c.name}"
      c.save!
    end
  end
end
