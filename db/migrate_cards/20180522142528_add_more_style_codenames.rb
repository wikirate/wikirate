# -*- encoding : utf-8 -*-

class AddMoreStyleCodenames < Card::Migration
  def up
    style_card :badges
    style_card :projects
    style_card :profiles
  end

  def style_card name
    ensure_card "style: #{name}",
                    codename: "style_#{name}", type_id: Card::ScssID

  end
end
