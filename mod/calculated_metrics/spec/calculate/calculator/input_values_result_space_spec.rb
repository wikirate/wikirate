require "./spec/support/company_ids"

RSpec.describe Calculate::Calculator::Input do
  include_context "with company ids"

  describe "result space" do
    def input_values formula
      f_card = Card["Jedi+friendliness+formula"]
      f_card.content = formula
      described_class.new f_card.parser
    end

    def result_cache formula
      iv = input_values(formula)
      iv.send :search_values_for
      iv.result_cache
    end

    def expect_result_space rc, hash
      hash.transform_values!(&:to_set)
      expect(rc).to eq hash
    end

    example "single metric" do
      rc = result_cache "{{Joe User+researched number 2}}"
      expect_result_space rc, 2014 => [samsung, sony], 2015 => [samsung]
    end

    example "two metrics" do
      rc = result_cache "{{Joe User+researched number 1}} + {{Joe User+RM}}"
      expect_result_space rc, 1977 => [death_star], 2015 => [apple], 2002 => [apple]
    end

    example "with not_researched option" do
      rc = result_cache "{{Joe User+researched number 1}} +"\
                               " {{Joe User+researched number 2| not_researched: 5}}"
      expect_result_space rc, 2014 => [samsung, sony], 2015 => [samsung, apple],
                              1977 => [death_star], 2002 => [apple]
    end

    example "without mandatory input items" do
      rc = result_cache "{{Joe User+researched number 1| not_researched: 0}} +"\
                               "{{Jedi+deadliness| not_researched: 5}}"
      expect_result_space rc,
                          2014 => [samsung, sony], 2015 => [samsung, apple],
                          1977 => [death_star, spectre, los_pollos, slate_rock, samsung],
                          2003 => [slate_rock], 2004 => [slate_rock],
                          2005 => [slate_rock], 2002 => [apple]
    end

    example "without mandatory input items and unknown option" do
      rc = result_cache "{{Joe User+researched number 1|"\
                               "not_researched: 0}} +"\
                               "{{Jedi+deadliness| not_researched: 5; unknown: 0}}"
      expect_result_space rc,
                          2014 => [samsung, sony], 2015 => [samsung, apple],
                          1977 => [death_star, spectre, los_pollos, slate_rock, samsung],
                          2003 => [slate_rock], 2004 => [slate_rock],
                          2005 => [slate_rock], 2002 => [apple]
    end
  end

  def input_values formula
    f_card = Card["Jedi+friendliness+formula"]
    f_card.content = formula
    described_class.new(f_card.parser)
  end

  def input_items formula
    iv = input_values formula
    iv.send :search_values_for
    iv.instance_variable_get("@input_list")
  end
end
