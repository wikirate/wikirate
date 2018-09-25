# -*- encoding : utf-8 -*-

class ConvertCurrencyToUnit < Card::Migration
  UNITS = { /^\$$/ => "USD", /US Dollars/ => "USD" }

  def up
    Card.search type: "Metric", right_plus: "currency" do |metric|
      if metric.value_type_code == :money
        standardize_money_metric metric
      else
        puts "SKIPPING #{metric.name}.\n" \
             "It has a currency card but its value type is not Money."
      end
    end
  end

  def standardize_money_metric metric
    currency_card = metric.fetch trait: :currency
    metric.fetch(trait: :unit)&.delete!
    currency_card.update_attributes! name: metric.name.field(:unit)
    standardize_units currency_card
  end

  def standardize_units currency_card
    old_unit = currency_card.content
    UNITS.each do |regexp, new_unit|
      if old_unit.match regexp
        currency_card.update_attributes! content: new_unit
        return
      end
    end
  end
end
