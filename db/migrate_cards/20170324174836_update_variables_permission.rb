# -*- encoding : utf-8 -*-

class UpdateVariablesPermission < Card::Migration
  def up
    ensure_trait "*variables", :variables,
                 update: "Anyone Signed In",
                 create: "Anyone Signed In",
                 delete: "Anyone Signed In"
  end
end
