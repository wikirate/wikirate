# -*- encoding : utf-8 -*-

class UpdateSystemEmails < Wagn::Migration
  def up

    #get rid of previous emails
    
    [:confirmation_email, :password_reset, :signup_alert].each do |email_template|
      etmpl = Card[email_template]
      etmpl.codename = nil
      etmpl.delete!
    end

    # create system email cards
    dir = "#{Wagn.gem_root}/db/migrate_cards/data/mailer"
    json = File.read( File.join( dir, 'mail_config.json' ))
    data = JSON.parse(json)
    data.each do |mail|
      mail = mail.symbolize_keys!
      Card.create! :name=> mail[:name], :codename=>mail[:codename], :type_id=>Card::EmailTemplateID
      Card.create! :name=>"#{mail[:name]}+*html message", :content=>File.read( File.join( dir, "#{mail[:codename]}.html" ))
      Card.create! :name=>"#{mail[:name]}+*text message", :content=>File.read( File.join( dir, "#{mail[:codename]}.txt" ))
      Card.create! :name=>"#{mail[:name]}+*subject", :content=>mail[:subject] 
    end
    
    
    # move old hard-coded signup alert email handling to new card-based on_create handling
    Card.create!(
      :name=>( [:signup, :type, :on_create].map { |code| Card[code].name } * '+'),
      :type_id=>Card::PointerID, :content=>"[[signup alert email]]"
    )
    if request_card = Card[:request]
      [:to, :from].each do |field|
        if old_card = request_card.fetch(:trait=>field) and !old_card.content.blank?
          Card.create! :name=>"signup alert email+#{Card[field].name}", :content=>old_card.content
        end
      end
      request_card.codename = nil
      request_card.delete!
    end
    
    # migrate old flexmail cards

    if email_config_card = Card['email_config']
      
      # FIXME - add email config migrations here...
      
      email_config_card.delete!
    end
    
    
    
    
    
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
