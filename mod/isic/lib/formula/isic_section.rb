module Formula
  # Calculator class to translate ISIC numbers to letters.
  class IsicSection < Isic
    letter_start_finish = [%w[A 01 03],
                           %w[B 05 09],
                           %w[C 10 33],
                           %w[D 35 35],
                           %w[E 36 39],
                           %w[F 41 43],
                           %w[G 45 47],
                           %w[H 49 53],
                           %w[I 55 56],
                           %w[J 58 63],
                           %w[K 64 66],
                           %w[L 68 68],
                           %w[M 69 75],
                           %w[N 77 82],
                           %w[O 84 84],
                           %w[P 85 85],
                           %w[Q 86 88],
                           %w[R 90 93],
                           %w[S 94 96],
                           %w[T 97 98],
                           %w[U 99 99]]

    NUM_TO_LETTER =
      letter_start_finish.each_with_object({}) do |(letter, start, finish), h|
        (start..finish).each { |num| h[num] = letter }
      end.freeze

    def value_for_validated_input input, _company, _year
      input.first.map { |num| NUM_TO_LETTER[num] }.uniq
    end
  end
end
