include_set Abstract::HamlFile

card_reader :title
card_reader :icon
card_reader :info

format :html do
  delegate :icon, :title, :info, to: :card

  def multi_card_editor?
    true
  end

  def nested_fields_for_edit
    [[:title],
     [:icon],
     [:info]]
  end
end
