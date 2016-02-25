# -*- encoding : utf-8 -*-

class Card
  #

  module CachedCount
    # contains blocks that get called with a card as argmuent and return
    # all cards that need cache update after a change to to that card
    @@expiry_checks = { delete: [], create: [], update: [], all: [], save: [] }
    mattr_accessor :expiry_checks # accessible in E and M

    def self.included(host_class)
      host_class.extend ClassMethods
      host_class.card_writer :cached_count, type: :plain_text
      host_class
    end

    def cached_count
      cached_count_card.content.to_i
    end

    module ClassMethods
      def recount_trigger set_of_changed_card, args={}, &block
        if set_of_changed_card
          args[:on] ||= [:create, :update, :delete]
          name = event_name set_of_changed_card, args
          set_of_changed_card.class_eval do
            event name, :integrate, args do
              Array.wrap(block.call(self)).compact.each do |expired_count_card|
                next unless expired_count_card.respond_to?(:update_cached_count)
                expired_count_card.update_cached_count
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

      def event_name set, args
        changed_card_set = set.to_s.tr(':', '_').underscore
        cached_count_set = to_s.tr(':', '_').underscore
        actions = Array.wrap args[:on]
        "update_#{cached_count_set}_cached_counts_changed_by_" \
        "#{changed_card_set}_on_#{actions.join('_')}".to_sym
      end
    end

    def update_cached_count
      return unless respond_to?(:calculate_count) &&
                    respond_to?(:cached_count_card)
      new_count = calculate_count
      return unless new_count
      Card::Auth.as_bot do
        if cached_count_card.new_card?
          cached_count_card.update_attributes! content: new_count.to_s
        elsif new_count.to_s != cached_count_card.content
          cached_count_card.update_column :db_content, new_count.to_s
          cached_count_card.expire
        end
      end
      new_count
    end

    # called to refresh the cached count
    # the default way is hthat the card is a search card and we just
    # count the search result
    # for special calculations override this method in your set
    def calculate_count
      count
    end
  end
end
