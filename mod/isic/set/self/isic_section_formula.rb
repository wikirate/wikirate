include_set Abstract::HardCodedFormula

letter_start_finish = [["A",	"01", "03"],
                       ["B",	"05", "09"],
                       ["C",	"10", "33"],
                       ["D",	"35", "35"],
                       ["E",	"36", "39"],
                       ["F",	"41", "43"],
                       ["G",	"45", "47"],
                       ["H",	"49", "53"],
                       ["I",	"55", "56"],
                       ["J",	"58", "63"],
                       ["K",	"64", "66"],
                       ["L",	"68", "68"],
                       ["M",	"69", "75"],
                       ["N",	"77", "82"],
                       ["O",	"84", "84"],
                       ["P",	"85", "85"],
                       ["Q",	"86", "88"],
                       ["R",	"90", "93"],
                       ["S",	"94", "96"],
                       ["T",	"97", "98"],
                       ["U",	"99", "99"]]

NUM_TO_LETTER =
  letter_start_finish.each_with_object({}) do |(letter, start, finish), h|
    (start..finish).each { |num| h[num] = letter }
  end.freeze

def get_value input
  input.first.map { | num| NUM_TO_LETTER[num] }.uniq
end

format :html do
  view :core do
    ["Translate number into letter category:", render_variable_metrics]
  end
end
