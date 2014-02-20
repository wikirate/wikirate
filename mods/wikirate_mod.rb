# -*- encoding : utf-8 -*-
class Card

  class SetPattern::LtypeRtypePattern < SetPattern
    class << self
      def label name
        %{All "#{name.to_name.left_name}" + "#{name.to_name.tag}" cards}
      end
      def prototype_args anchor
        { }
      end
      def anchor_name card
        left, right = card.left, card.right
        ltype_name = (left && left.type_name) || Card[ Card.default_type_id ].name
        rtype_name = (right && right.type_name) || Card[ Card.default_type_id ].name
        "#{ltype_name}+#{rtype_name}"
      end
    end
    register 'ltype_rtype', :opt_keys=>[:ltype, :rtype], :junction_only=>true, :assigns_type=>true, :index=>4
    
  end
end


