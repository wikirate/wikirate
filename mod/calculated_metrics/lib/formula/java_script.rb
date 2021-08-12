require "execjs"

module Formula
  # Calculate formula values using JavaScript
  class JavaScript < NestCalculator
    def compile
      "calc = function(iN) { return (#{js_formula}) }"
    end

    def js_formula
      replace_nests { |index| input_name index }
    end

    def compute input, _c, _v
      computer.call "calc", prepare_values(input)
    end

    def boot
      ExecJS.compile program
    end

    private

    def prepare_values input
      input.map.with_index do |value, index|
        ruby_value value, index
      end
    end

    def ruby_value value, index
      case value
      when Array
        value.map { |v| ruby_value v, index }
      when "false"
        false
      when "nil"
        nil
      when "Unknown"
        value
      else
        numeric?(index) ? value.to_f : value
      end
    end

    def numeric? index
      @numeric ||= {}
      return @numeric[index] unless @numeric[index].nil?
      @numeric[index] = input.type(index).in? %i[number yearly_value]
    end


    # just weird enough that users aren't likely to use it...
    def input_name index
      "iN[#{index}]"
    end
  end
end
