class Card
  class Content
    module Chunk
      class FormulaInput < Nest
        Card::View::Options.add_option :year, :shark
        Card::View::Options.add_option :company, :shark
        Card::View::Options.add_option :unknown, :shark
        Card::View::Options.add_option :not_researched, :shark
        DEFAULT_OPTION = :year

        Card::Content::Chunk.register_class(
          self, prefix_re: '\\{\\{',
                full_re:    /\A\{\{([^\}]*)\}\}/,
                idx_char:  "{"
        )
      end

      register_list :formula, [:FormulaInput]
    end
  end
end
