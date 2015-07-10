# -*- encoding : utf-8 -*-

# Used to extend setting modules like Card::Set::Self::Create in the settings mod

class Card
  module CachedCount

    # contains blocks that get called with a card as argmuent and return
    # all cards that need cache update after a change to to that card
    @@update_triggers = {:delete=>[], :create=>[], :update=>[], :all=>[]}
    mattr_accessor :update_triggers  # accessible in E and M
    def self.included(host_class)
      host_class.extend ClassMethods
      host_class.card_accessor :cached_count, :type=>:number, :default=>'0'
      host_class
    end

    module ClassMethods
      def expired_cached_counts args={}, &block
        on_action = args[:on] || :all
        Array.wrap(on_action).each do |a|
          Card::CachedCount.update_triggers[a] << block
        end
      end
    end

    def run_update_triggers action
      Card::CachedCount.update_triggers[action].each do |block|
        if (expired = block.call(self))
          Array.wrap(expired).each do |item|
            item.update_cached_count if item.respond_to? :update_cached_count
          end
        end
      end
    end

    def update_cached_count
      if respond_to?(:calculate_count) && respond_to?(:cached_count_card)
        new_count = calculate_count
        Card::Auth.as_bot do
          if cached_count_card.new_card?
            cached_count_card.update_attributes!(:content => new_count.to_s)
          else
            cached_count_card.update_column(:db_content, new_count.to_s)
            cached_count_card.expire
          end
        end
      end
    end

    # called to refresh the cached count
    # the default way is hthat the card is a search card and we just count the search result
    # for special calculations override this method in your set
    def calculate_count
      count
    end

 end
end