class CategoryValueValidator
  attr_reader :keys

  def initialize metric_card
    @metric_card = metric_card
    @values = Answer.where(metric_id: @metric_card.id).select(:value).distinct
    @value_options = @metric_card.value_options
    initialize_keys
  end

  def initialize_keys
    @key_to_name ||= {}
    @keys = @values.map do |n|
      key = n.value.to_name.key
      @key_to_name[key] = n.value
    end
  end

  def invalid_values?
    invalid_count > 0
  end

  def invalid_count
    invalid_keys.size
  end

  def invalid_keys
    @invalid_keys ||= keys - valid_category_keys
  end

  def invalid_values
    invalid_keys.map do |k|
      link_to_answer(name(k)).html_safe
    end
  end

  def name key
    @key_to_name[key]
  end

  def valid_category_keys
    keys = @value_options.map { |n| n.to_name.key }
    keys << "unknown"
  end

  def error_msg
    msg =
      if invalid_count == 1
        "#{invalid_values.to_sentence} is not a valid option for this metric. "\
        "Please add those options"
      else
        "#{invalid_values.to_sentence} are not valid options for this metric. "\
        "Please add those option"
      end
    msg + " #{link_to_edit_options} first."
  end

  def link_to_answer value
    #search = %({"left":{"left":{"left_id":"#{@metric_card.id}"}}, "content":"#{value}"})
    search = <<-JSON.strip_heredoc.delete("\n")
      {"left":{"left_id":"#{@metric_card.id}"},
      "right_plus":["value",{"content":"#{value}"}]}
    JSON
    title = "Answers with invalid option \"#{value}\""
    @metric_card.format.link_to_card(:search, value,
                                     path: { "_keyword": search, slot: { title: title } })
  end

  def link_to_edit_options
    @metric_card.format.link_to_card @metric_card.value_options_card,
                                     "to the options card",
                                     path: { view: :edit }, target: "_blank"
  end
end

include_set Abstract::MetricChild, generation: 1

event :validate_type_of_existing_values, :validate,
      on: :save, changed: :content do
  case value_type
  when "Number", "Money" then validate_numeric_values
  when "Category" then validate_categorical_values
  end
end

def validate_categorical_values
  validator = CategoryValueValidator.new left
  return unless validator.invalid_values?
  add_categorical_error validator
end

def validate_numeric_values
  metric_card.all_answers.find do |answer|
    next if valid_numeric_value? answer.value
    add_numeric_error answer
  end
end

def valid_numeric_value? value
  number?(value) || Answer.unknown?(value)
end

def add_numeric_error answer
  errors.add Card.fetch_name(answer.answer_id),
             "'#{answer.value}' is not a numeric value."
end

def add_categorical_error validator
  errors.add :value, validator.error_msg
end

format :html do
  def default_edit_args _args
    voo.title = "Value Type"
  end

  def multi_card_edit
    super() + fields_form
  end

  def single_card_edit_field
    super() + fields_form
  end

  def editor_in_multi_card
    super() + fields_form
  end

  def left_field_nest field, opts
    if card.name.left_name.empty?
      parent.field_nest field, opts
    else
      nest card.name.left_name.field_name(field), opts
    end
  end

  def fields_form
    <<-HTML.html_safe
      <div class='value_type_field number_details'>
        #{left_field_nest :unit, title: 'Unit', type: :phrase}
        #{left_field_nest :range, title: 'Range', type: :phrase}
      </div>
      <div class='value_type_field category_details'>
        #{left_field_nest :value_options, view: :edit_in_form, title: 'Value Options',
                                          type: :pointer}
      </div>
      <div class='value_type_field currency_details'>
        #{left_field_nest :currency, view: :edit_in_form,
                                     title: 'Currency', type: :phrase}
      </div>
    HTML
  end
end
