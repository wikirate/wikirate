# -*- encoding : utf-8 -*-

class StyleFilter < Card::Migration
  def up
    create_or_update name: 'style_filter',
                     type_id: Card::ScssID,
                     codename: 'style_filter'
  end
end
