# -*- encoding : utf-8 -*-

class MetricEditor < Card::Migration
  def up
    create_session_card 'variables'
    Card::Cache.reset_all
  end

  def create_session_card codename
    name = "*#{codename}"
    create_card! name: name, codename: codename
    create_card! name: "*#{name}+*right+*default",
                 type_id: Card::SessionID
  end
end
