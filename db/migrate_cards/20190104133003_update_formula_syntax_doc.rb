# -*- encoding : utf-8 -*-

class UpdateFormulaSyntaxDoc < Cardio::Migration
  def up
    merge_cards :formula_syntax
  end
end

