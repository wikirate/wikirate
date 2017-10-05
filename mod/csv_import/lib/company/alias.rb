# -*- encoding : utf-8 -*-
require_dependency "card/cache"

module Company
  # Company::Alias caches alias names for companies.
  # The alias names are taken from the "+aliases" cards on the company cards.
  # It is used in the import tool to map company names in csv files
  # to company names in wikirate's database.
  class Alias
    class << self
      CACHE_KEY = "ALIASHASH"
      # returns true company name for an alias company name
      # @param company [String]
      # @return [String]
      def [] company
        return if company.nil?
        aliashash[company.to_name.key]
      end

      # a Hash with string keys and string values
      # @return [Hash]
      def aliashash
        @aliashash ||= load_aliashash
      end

      # clear cache both locally and in cache
      def reset_cache
        @aliashash = nil
        Card.cache.delete CACHE_KEY
      end

      private

      # iterate through every alias card
      # @yieldparam aliascard [Card]
      def all_alias_cards
        Card.search right: { codename: "aliases" } ,
                    left: { type_id: Card::WikirateCompanyID }
      end

      def check_duplicates aliashash, alias_key, true_name
        return unless aliashash.key?(alias_key)
        warn "dup alias: #{alias_key} for #{aliashash[alias_key]} and #{true_name}"
      end

      # generate Hash for @aliashash and put it in the cache
      def load_aliashash
        Card.cache.fetch(CACHE_KEY) do
          generate_aliashash
        end
      end

      def generate_aliashash
        all_alias_cards.each_with_object({}) do |alias_card, hash|
          true_name = alias_card.cardname.left
          alias_card.item_names.each do |alias_name|
            alias_key = alias_name.to_name.key
            check_duplicates hash, alias_key, true_name
            hash[alias_key] = true_name
          end
        end
      end
    end
  end
end
