# -*- encoding : utf-8 -*-

class AddSubprojectCards < Card::Migration
  def up
    merge_cards %w[
                    parent
                    parent+*right+*default
                    project+parent+*type_plus_right+*options
                    subproject
                    subproject+*right+*structure
                  ]
  end
end
