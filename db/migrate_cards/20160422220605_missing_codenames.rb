# -*- encoding : utf-8 -*-

class MissingCodenames < Card::Migration
  def up
    %w(unit value_options currency category number money
       numeric_details monetary_details category_details
       aliases).each do |codename|
      update_card codename, codename: codename
    end
  end
end
