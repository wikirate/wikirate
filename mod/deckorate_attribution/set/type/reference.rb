include_set Abstract::Export

card_accessor :adaptation, type: :pointer
card_accessor :party, type: :list
card_accessor :url, type: :uri
card_accessor :wikirate_title, type: :phrase
card_accessor :subject, type: :pointer
card_accessor :file

require_field :subject
require_field :adaptation
require_field :party, when: :party_required?

event :store_attribution_snapshot, :integrate_with_delay, on: :create do
  handle_file csv_dump_content do |tmpfile|
    file_card.file = tmpfile
    file_card.save!
  end
end

def subject_item_card
  subject_card.first_card
end

def ok_to_update?
  Auth.signed_in? && ((Auth.current_id == creator_id) || Auth.current.stewards_all?)
end

def ok_to_delete?
  ok_to_update?
end

private

def party_required?
  field(:adaptation).first_card&.codename == :yes_adaptation
end

format :html do
  bar_cols 6, 6

  before :new do
    voo.hide! :header
  end

  before :edit do
    voo.title = attribution_message
  end

  view :bar_left, template: :haml
  view :modal_footer, template: :haml, unknown: true

  view :modal_title do
    attribution_message
  end

  view :bar_right, template: :haml

  view :new_buttons do
    haml :tabs_placeholder
  end

  view :edit_buttons do
    [render_attributions, super()]
  end

  view :attributions do
    tabs "Rich Text" => { content: render_rich_text_attrib },
         "Plain Text" => { content:  render_plain_text_attrib },
         "HTML" => { content: render_html_attrib }
  end

  view :attributions_placeholder, unknown: true do
    tabs "Rich Text" => {},
         "Plain Text" => {},
         "HTML" => {}
  end

  view :rich_text_attrib do
    attribution_box { render_attribute }
  end

  view :plain_text_attrib do
    attribution_box { h card.format(:text).render_attribute }
  end

  view :html_attrib, cache: :never do
    attribution_box { h render_attribute }
  end

  def attribution_box
    haml :attribution_box, content: yield
  end

  def new_form_opts
    {
      "data-slot-selector": ".TYPE-reference.new_buttons-view",
      success: { view: :attributions }
    }
  end

  def edit_fields
    [
      :subject,
      [:adaptation, title: "Adaptation"],
      [:party, title: "Person or Organization"],
      [:wikirate_title, title: "Title"],
      [:url, title: "URL"]
    ]
  end

  view :core do
    edit_fields.map do |fld|
      field_nest Array.wrap(fld).first, view: :titled
    end
  end

  def attribution_message
    with_nest_mode :normal do
      haml :attribution_message
    end
  end

  # should be removable once help rule card is gone.
  def raw_help_text
    nil
  end

  before :bar do
    voo.hide :bar_menu unless card.ok? :update
  end

  def bar_menu_items
    class_up "edit-link", "_modal-page-link"

    [edit_link(:edit, text: "Edit")]
  end
end

format do
  view :attribute, cache: :never do
    with_nest_mode :normal do
      %i[wikirate title adaptation license].map do |section|
        attribution_section section
      end.compact.join ", "
    end
  end

  view :att_adaptation do
    return unless adaptation?

    adapters = card.party_card.item_names
    return "adaptation" unless adapters.first.present?

    "adaptation by #{adapters.to_sentence}"
  end

  def attribution_section section
    if section == :adaptation
      render_att_adaptation
    else
      nest card.subject, view: "att_#{section}"
    end
  end

  def adaptation?
    card.adaptation_card&.first_card&.codename == :yes_adaptation
  end
end

format :csv do
  view :titles do
    ::Answer.csv_titles true
  end

  view :body do
    nest card.subject, view: :reference_dump_core
  end
end

private

# FIXME: this #handle_file business should not be necessary!
# it is copied from vendor/decko/mod/assets/set/abstract/asset_outputter.rb
# it *probably* shouldn't be necessary there.
# it *definitely* shouldn't be necessary here.
#
# The StringIO solution below (don't uncomment or remove until above is addressed!)
# should work. as in card.update file: StringIO.new(string)

def handle_file output
  f = Tempfile.new [id.to_s, ".csv"]
  f.write output
  f.close
  yield f
  f.unlink
end

# def csv_dump_file
#   StringIO.new csv_dump_content
# end

def csv_dump_content
  format(:csv).show :titled, {}
end
