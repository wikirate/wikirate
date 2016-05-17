# -*- encoding : utf-8 -*-

class MissingCodenames < Card::Migration
  def up
    %w(unit value_options currency number
       numeric_details monetary_details category_details
       aliases).each do |codename|
      puts "update #{codename}"
      update_card codename, codename: codename
    end
  end
end
