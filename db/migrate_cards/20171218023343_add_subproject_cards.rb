# -*- encoding : utf-8 -*-

class AddSubprojectCards < Card::Migration
  def up
    merge_cards %w[
                    parent
                    parent+*right+*default
                    project+parent+*type plus right+*options
                    subproject
                    subproject+*right+*structure
                  ]
  end
end
