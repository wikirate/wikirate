class Calculate
  class Parser
    Card::Content::Chunk.register_list :formula, [:FormulaInput]

    OPTIONS = %i[year company unknown not_researched].freeze

    attr_reader :input_names, :formula
    alias_method :item_names, :input_names

    def initialize formula, input_names=nil, card=nil
      @formula = formula
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

    def input_ids
      @input_ids ||= input_names.map(&:card_id)
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

    def unknown_options
      @unknown = special_options @unknown_handling, :unknown_string, :unknown, "Unknown"
    end

    def not_researched_options
      @not_researched = special_options @not_researched_handling, :no_value_string,
                                        :not_researched, "No value"
    end

    def special_options handling, string_handling, options_key, string_value
      case handling
      when string_handling
        [string_value] * input_count
      when :process
        input_options(options_key).map { |i| i || string_value }
      else
        input_options options_key
      end
    end

    # Look up all input values and don't apply input options like {{ | unknown: 4 }}
    def raw_input!
      unknown_handling :unknown_string
      not_researched_handling :no_value_string
      self
    end

    # Look up all input values. Apply input options if present otherwise
    # pass raw value
    def processed_input!
      unknown_handling :process
      not_researched_handling :process
      self
    end

    # Define how to handle input values that are unknown
    # @param option [:process, :abort, :unknown_string]
    #    abort: (default) return :unknown as calculation result
    #    unknown_string: pass it as "Unknown" to the formula ignoring unknown options
    #    process: if formula specifies unknown handling use it otherwise pass as "Unknown"
    def unknown_handling option
      unless option.in? [:process, :abort, :unknown_string]
        raise  "unknown option for unknown handling"
      end
      @unknown_handling = option
    end

    # Define how to handle input values that are not researched
    # @param option [:process, :abort, :no_value_string]
    #    abort: (default) return nil as calculation result
    #    no_value_string: pass it as "No value" to the formula ignoring not researched
    #                     options
    #    process: if formula specifies not researched handling use it otherwise pass as
    #             "No value"
    def not_researched_handling option
      unless option.in? [:process, :abort, :no_value_string]
        raise  "unknown option for not researched handling"
      end
      @not_researched_handling = option
    end

    private

    def pick_option_value opt, index
      send("#{opt}_options").at(index)&.sub("#{opt}:", "")&.strip
    end

    def find_input_chunks
      content_object.find_chunks :FormulaInput
    end

    def content_object
      Card::Content.new @formula, @card, chunk_list: :formula
    end

    def input_options option_name
      input_chunks.map do |chunk|
        chunk.options[option_name]
      end
    end
  end
end
