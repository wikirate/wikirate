# -*- encoding : utf-8 -*-

class AddCodenameForProgramsType < Cardio::Migration
  def up
    ensure_card "Program", type: Card::CardtypeID, codename: "program"
  end
end
