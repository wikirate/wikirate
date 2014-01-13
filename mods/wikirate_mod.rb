# -*- encoding : utf-8 -*-
class Card
  #module Set  
  #  module TypePlusRight
  #    module Claim
  #      module WikirateTopic
  #        extend Set
  #        
  #        #explicitly override js topic tree
  #        view :editor, :ltype=>:claim, :right=>:wikirate_topic do |args|  
  #          _final_pointer_type_editor args
  #        end
  #        
  #        def options; options_restricted_by_source; end
  #      end
  #      
  #      module WikirateCompany
  #        extend Set
  #        def options; options_restricted_by_source; end
  #      end
  #      
  #      module WikirateMarket
  #        extend Set
  #        def options; options_restricted_by_source; end
  #      end          
  #    end
  #  end
  #
  #end
  
#  raise "woot"

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


