# -*- encoding : utf-8 -*-
require "pry"
class AddVerificationIndex < Cardio::Migration::DeckStructure
  def change
    # binding.pry
    add_index :answers, :verification #, name: "verification_index"
  end
end
