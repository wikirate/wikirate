# -*- encoding : utf-8 -*-

class AddSourceTypeRightStructure < Card::Migration
  def up
    # create_card! name: '*source type+*right+*structure',
    #              type_id: Card::SetID,
    #              content: '{"type":"source",' \
    #                       '"right_plus":["*source type",{"refer_to":"_left"}]}'
  end
end
