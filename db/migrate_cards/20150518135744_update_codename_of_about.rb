# -*- encoding : utf-8 -*-

class UpdateCodenameOfAbout < Card::Migration
  def up
    about_card = Card["about"]
    about_card.codename = "about"
    about_card.save!
  end
end
