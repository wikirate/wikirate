# -*- encoding : utf-8 -*-

class ResearchPage < Card::Migration
  def up
    ensure_card "Research Page", type_id: Card::SessionID,
                codename: "research_page"

    ensure_field_rules "Company"
    ensure_field_rules "Metric"

    ensure_card "Unknown", codename: "unknown"
    ensure_card "Unknown+*right+*input", content: "checkbox"
    ensure_card "Unknown+*right+*help",
                content: "When you cannot find an answer in the relevant documents, select <em>'Unknown'</em>"
    ensure_card "Unknown+*right+*default", type_id: Card::ToggleID

    # ensure_card "Metric value+company+*type plus right+*input",
    #             content: "select"
  end

  def ensure_field_rules field
    ensure_card "Session+#{field}+*type plus right+*default",
                type_id: Card::SessionID
    ensure_card "Session+#{field}+*type plus right+*input",
                content: "select"
    ensure_card "value+*right+*default", type_id: Card::PhraseID
  end
end
