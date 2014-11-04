# -*- encoding : utf-8 -*-

class UpdateSystemEmails < Wagn::Migration
  def up
    dir = "#{Wagn.gem_root}/db/migrate_cards/data/mailer"
    json = File.read( File.join( dir, 'mail_config.json' ))
    data = JSON.parse(json)
    data.each do |mail|
      mail = mail.symbolize_keys!
      Card.fetch("#{mail[:name]}+*html message").update_attributes! :content=>File.read( File.join( dir, "#{mail[:codename]}.html" ))
      Card.fetch("#{mail[:name]}+*text message").update_attributes! :content=>File.read( File.join( dir, "#{mail[:codename]}.txt" ))
      Card.fetch("#{mail[:name]}+*subject").update_attributes! :content=>mail[:subject] 
    end
  end
end
