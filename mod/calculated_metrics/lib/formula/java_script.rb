require "execjs"

module Formula
  # Calculate formula values using JavaScript
  class JavaScript < NestCalculator
    def build_executable
      replace_nests { |index| input_name index }
    end

    def get_value input, _c, _v
      ExecJS.eval "iN = #{input.to_json}; #{executable}"
    end

    def execute
      get_value [], nil, nil
    end

    private

    # just weird enough that users aren't likely to use it...
    def input_name index
      "iN[#{index}]"
    end
  end
end
