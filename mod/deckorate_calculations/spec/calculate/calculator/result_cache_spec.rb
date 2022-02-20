RSpec.describe Calculate::Calculator::ResultCache do
  include_context "with company ids"

  describe "result space" do
    def result_cache *input_array
      i = Calculate::Calculator::Input.new input_array
      i.send :search_values_for
      i.result_cache
    end

    def expect_result_space rc, hash
      hash.transform_values!(&:to_set)
      expect(rc).to eq hash
    end

    example "single metric" do
      rc = result_cache metric: "Joe User+researched number 2"
      expect_result_space rc, 2014 => [samsung, sony], 2015 => [samsung]
    end

    example "two metrics" do
      rc = result_cache({ metric: "Joe User+researched number 1" },
                        { metric: "Joe User+RM" })
      expect_result_space rc, 1977 => [death_star], 2015 => [apple], 2002 => [apple]
    end

    example "with not_researched option" do
      rc = result_cache({ metric: "Joe User+researched number 1" },
                        { metric: "Joe User+researched number 2", not_researched: "5" })
      expect_result_space rc, 2014 => [samsung, sony], 2015 => [samsung, apple],
                              1977 => [death_star], 2002 => [apple]
    end

    example "without mandatory input items" do
      rc = result_cache({ metric: "Joe User+researched number 1", not_researched: "0" },
                        { metric: "Jedi+deadliness", not_researched: "5" })
      expect_result_space rc,
                          2014 => [samsung, sony], 2015 => [samsung, apple],
                          1977 => [death_star, spectre, los_pollos, slate_rock, samsung],
                          2003 => [slate_rock], 2004 => [slate_rock],
                          2005 => [slate_rock], 2002 => [apple]
    end

    example "without mandatory input items and unknown option" do
      rc = result_cache({ metric: "Joe User+researched number 1", not_researched: "0" },
                        { metric: "Jedi+deadliness", not_researched: "5", unknown: "0" })
      expect_result_space rc,
                          2014 => [samsung, sony], 2015 => [samsung, apple],
                          1977 => [death_star, spectre, los_pollos, slate_rock, samsung],
                          2003 => [slate_rock], 2004 => [slate_rock],
                          2005 => [slate_rock], 2002 => [apple]
    end
  end
end
