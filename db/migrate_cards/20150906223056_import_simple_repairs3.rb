# -*- encoding : utf-8 -*-

class ImportSimpleRepairs3 < Card::Migration
  def up
    import_json "simple_repairs3.json"
  end
end
