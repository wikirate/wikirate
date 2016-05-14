# -*- encoding : utf-8 -*-

class AddCodenamesCard < Card::CoreMigration
  def up
    create_or_update '*codenames',
                     codename: 'codenames',
                     type_id: Card::SearchTypeID,
                     content: '{"codename":["ne",""]}'
    create_or_update 'production export',
                     codename: 'production_export',
                     type_id: Card::PointerID
  end
end
