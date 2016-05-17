# -*- encoding : utf-8 -*-

class UpdateSystemEmails < Card::Migration
  def up

    #get rid of previous emails
    
    [:confirmation_email, :password_reset, :signup_alert].each do |email_template|
      etmpl = Card[email_template]
      etmpl.codename = nil
      etmpl.delete!
    end


    # change email address list fields to pointers
    [:to, :from, :cc, :bcc].each do |field|
      set = Card[field].fetch(:trait=>:right, :new=>{})
      default_rule = set.fetch(:trait=>:default, :new=>{})
      default_rule.type_id = Card::PointerID
      default_rule.save!
      
      options_rule = set.fetch(:trait=>:options, :new=>{})
      options_rule.type_id = Card::SearchID
      options_rule.content = %( { "right":{"codename":"account"} } )
      options_rule.save!
    end

    # create system email cards
    dir = "#{Wagn.gem_root}/db/migrate_cards/data/mailer"
    json = File.read( File.join( dir, "mail_config.json" ))
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
      :name=>( [:signup, :type, :on_create].map { |code| Card[code].name } * "+"),
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
    
    
    signup_alert_from = Card["signup alert email"].fetch(:trait=>:from, :new=>{})
    if signup_alert_from.content.blank?
      signup_alert_from.content = "_user"
      signup_alert_from.save!
    end
    
    # migrate old flexmail cards

    if email_config_card = Card["email_config"]
      
      # FIXME - add email config migrations here...
      
      email_config_card.delete!
    end
    
    

    
  end
end
