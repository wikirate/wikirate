# -*- encoding : utf-8 -*-

class AddVerificationIndex < Cardio::Migration::DeckStructure
  def change
    add_index :answers, :verification # , name: "verification_index"
  end
end
