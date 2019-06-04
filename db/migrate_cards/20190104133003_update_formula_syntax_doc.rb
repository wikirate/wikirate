# -*- encoding : utf-8 -*-

class UpdateFormulaSyntaxDoc < Card::Migration
  def up
    merge_cards :formula_syntax
  end
end

