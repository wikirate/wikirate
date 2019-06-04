module Formula
  class Parser
    OPTIONS = %i[year company unknown not_researched].freeze
    COUNT_RELATED_FUNC =
      { "CountRelated" => "Total[ {{always one|company: Related" }.freeze

    attr_reader :input_names, :formula
    alias_method :item_names, :input_names

    def initialize formula, input_names=nil, card=nil
      @formula = translate_shortcuts formula
      @card = card || Card.new # only needed for the content object
      @input_names = input_names || standard_input_names
    end

    def standard_input_names
      input_chunks.map { |chunk| chunk.referee_name.to_s }
    end

    def input_keys
      @input_keys ||= input_names.map { |m| m.to_name.key }
    end

    def input_chunks
      @input_chunks ||= find_input_chunks
    end

    def input_count
      input_names.size
    end

    def input_cards
      @input_cards ||= input_names.map { |name| Card.fetch name }
    end

    OPTIONS.each do |opt|
      define_method "#{opt}_options" do
        instance_variable_get("@#{opt}") ||
          instance_variable_set("@#{opt}", input_options(opt))
      end

      define_method "#{opt}_option" do |index|
        pick_option_value opt, index
      end
    end

    private

    def pick_option_value opt, index
      send("#{opt}_options").at(index)&.sub("#{opt}:", "")&.strip
    end

    def find_input_chunks
      content_object.find_chunks(Card::Content::Chunk::FormulaInput)
    end

    def content_object
      Card::Content.new @formula, @card, chunk_list: :formula
    end

    def input_options option_name
      input_chunks.map do |chunk|
        chunk.options[option_name]
      end
    end

    def translate_shortcuts formula
      count_related_replacer.translate formula
    end

    def count_related_replacer
      Calculator::FunctionTranslator.new(COUNT_RELATED_FUNC) do |replacement, arg|
        "#{replacement}[#{arg}]}} ]"
      end
    end
  end
end
