# -*- encoding : utf-8 -*-

class Card
  module CachedCount
    # contains blocks that get called with a card as argmuent and return
    # all cards that need cache update after a change to to that card
    @@expiry_checks = { delete: [], create: [], update: [], all: [], save: [] }
    mattr_accessor :expiry_checks # accessible in E and M

    def self.included(host_class)
      host_class.extend ClassMethods
      host_class.card_writer :cached_count, :type=>:plaintext
      host_class
    end

    def cached_count
      count = cached_count_card.content
      count.present? ? count.to_i : update_cached_count
    end

    module ClassMethods

      def expired_cached_count_cards args={}, &block
        if args[:set]
          set_name = args[:set].to_s.gsub(':','').underscore
          on_actions = Array.wrap(args[:on]) || [:create, :update, :delete]
          event_name = "update_cached_counts_for_set_#{set_name}_on_#{on_actions.join('_')}"
          args[:set].class_eval do
            event event_name.to_sym, :on => on_actions, :after=>:extend do
              Array.wrap(block.call(self)).compact.each do |expired_count_card|
                if expired_count_card.respond_to?(:update_cached_count)
                  expired_count_card.update_cached_count
                end
              end
            end
          end
        else
          on_actions = args[:on] || :all
          Array.wrap(on_actions).each do |a|
            Card::CachedCount.expiry_checks[a] << block
          end
        end
      end
    end

    def update_cached_count
      if respond_to?(:calculate_count) && respond_to?(:cached_count_card)
        new_count = calculate_count
        #return if new_count == 0
        Card::Auth.as_bot do
          if cached_count_card.new_card?
            cached_count_card.update_attributes!(:content => new_count.to_s)
          else
            cached_count_card.update_column(:db_content, new_count.to_s)
            cached_count_card.expire
          end
        end
        new_count
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