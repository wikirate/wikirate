
require "net/https"
require "uri"

def number? str
  true if Float(str)
rescue
  false
end

format do
  view :cite, closed: true do
    ""
  end

  view :raw_or_blank, perms: :none, closed: true do
    _render_raw || ""
  end
end

format :html do
  view :cgi_escape_name do
    CGI.escape card.name
  end

  view :og_source, tags: :unknown_ok do |args|
    if card.real?
      card.format.render_source
    else
      Card["*Vertical_Logo"].format.render_source args.merge(size: "large")
    end
  end

  view :meta_preview do |args|
    content = _render_core args
    truncated = Card::Content.smart_truncate content, 50
    ActionView::Base.full_sanitizer.sanitize truncated
  end

  view :progress_bar do
    value = card.raw_content
    if card.number? value
      <<-HTML
        <div class="progress">
           <div class="progress-bar" role="progressbar" aria-valuenow="#{value}"
            aria-valuemin="0" aria-valuemax="100" style="width: #{value}%;">
            #{value}%
          </div>
        </div>
      HTML

    else
      "Only card with numeric content can be shown as progress bar."
    end
  end

  view :titled_with_edits do
    @content_body = true
    wrap do
      [
        _render_header,
        render_edits_by,
        wrap_body { _render_core }
      ]
    end
  end

  view :edits_by do
    editor_card = card.fetch trait: :editors
    links = subformat(editor_card).render_shorter_search_result(
      items: { view: :link }
    )
    %(<div class="edits-by">
        #{links}<div class='subtitle-header'>Edits by</div>
      </div>
    )
  end

  view :open do
    voo.show :horizontal_menu
    super()
  end

  attr_accessor :citations

  def menu_icon
    glyphicon "edit"
  end

  def default_menu_args args
    args[:optional_horizontal_menu] ||= :show if main?
  end

  view :shorter_pointer_content do
    voo.hide :link
    subformat(card).render_shorter_search_result
  end

  view :shorter_search_result do
    render_view = voo.show?(:link) ? :link : :name
    items = card.item_cards limit: 0
    total_number = items.size
    fetch_number = [total_number, 4].min

    result = ""
    if fetch_number > 1
      result += items[0..(fetch_number - 2)].map do |c|
        subformat(c).render(render_view)
      end.join(" , ")
      result += " and "
    end

    result +
      if total_number > fetch_number
        %(<a class="known-card" href="#{card.format.render :url}"> ) \
          "#{total_number - 3} others</a>"
      else
        subformat(items[fetch_number - 1]).render(render_view)
      end
  end

  view :name_formgroup do
    # force showing help text
    voo.help ||= true
    super()
  end

  view :cite, cache: :never do
    # href_root = parent ? parent.card.cardname.trunk_name.url_key : ''
    wrap_with :sup do
      wrap_with :a, class: "citation", href: "##{card.cardname.url_key}" do
        cite!
      end
    end
  end

  def cite!
    holder = parent.parent || parent || self
    holder.citations ||= []
    holder.citations << card.key
    holder.citations.size
  end

  view :wikirate_modal do
    card_name = Card::Env.params[:show_modal]
    if card_name.present?
      after_card = Card[card_name]
      if !after_card
        Rails.logger.info "Expect #{card_name} exist"
        "" # otherwise it will return true
      else
        "<div class='modal-window'>#{subformat(after_card).render_core} </div>"
      end
    else
      ""
    end
  end

  view :yinyang_list do |args|
    wrap_with :div, class: "yinyang-list #{args[:yinyang_list_class]}" do
      _render_yinyang_list_items(args)
    end
  end

  view :showcase_list, tags: :unknown_ok do |args|
    item_type_name = card.cardname.right.split.last
    icon_card = Card.fetch("#{item_type_name}+icon")
    hidden_class = card.content.empty? ? "hidden" : ""
    class_up "card-body", "showcase #{hidden_class}"
    wrap do
      %(
        #{subformat(icon_card)._render_core}
        #{item_type_name.capitalize}
        #{_render_core(args)}
      )
    end
  end

  view :open_contribution_list do |args|
    _render_open(args.merge(contribution_list: true))
  end

  view :yinyang_list_items do |args|
    joint = args[:joint] || " "

    enrich_result(card.item_names).map do |icard|
      wrap_with :div, class: "yinyang-row" do
        nest_item(icard, view: args[:item]).html_safe
      end.html_safe
    end.join(joint).html_safe
  end

  def enrich_result result
    result.map do |item_name|
      # 1) add the main card name on the left
      # for example if "Apple+metric+*upvotes+votee search" finds "a metric"
      # we add "Apple" to the left
      # because we need it to show the metric values of "a metric+apple"
      # in the view of that item
      # 2) add "yinyang drag item" on the right
      # this way we can make sure that the card always exists with a
      # "yinyang drag item+*right" structure
      Card.fetch main_name, item_name, "yinyang drag item"
    end
  end

  def main_name
    left_name = card.cardname.left_name
    left_name = left_name.left unless card.key.include?("limited_metric")
    @main_name ||= left_name
  end

  def main_type_id
    @main_type_id ||= Card.fetch(main_name).type_id
  end

  def searched_type_id
    @searched_type_id ||= Card.fetch_id card.cardname.left_name.right
  end
end


if Card::Codename[:claim]
  CLAIM_SUBJECT_SQL = %{
    select subjects.`key` as subject, claims.id from cards claims
    join cards as pointers on claims.id   = pointers.left_id
    join card_references   on pointers.id = referer_id
    join cards as subjects on referee_id  = subjects.id
    where claims.type_id = #{Card::ClaimID}
    and pointers.right_id in
      (#{[Card::WikirateTopicID, Card::WikirateCompanyID].join(', ')})
    and claims.trash   is false
    and pointers.trash is false
    and subjects.trash is false;
  }
end

# some wikirate specific methods
module ClassMethods
  def claim_count_cache
    Card::Cache[Card::Set::Right::WikirateClaimCount]
  end

  def claim_counts subj
    ccc = claim_count_cache
    ccc.read(subj) || begin
      subjname = subj.to_name
      count = claim_subjects.count do |_id, subjects|
        if subjname.simple?
          subjects_apply? subjects, subj
        else
          subjects_apply?(subjects, subjname.left) &&
            subjects_apply?(subjects, subjname.right)
        end
      end
      ccc.write subj, count
    end
  end

  def subjects_apply? references, test_list
    !!Array.wrap(test_list).find do |subject|
      references.member? subject
    end
  end

  def claim_subjects
    ccc = claim_count_cache
    ccc.read("CLAIM-SUBJECTS") || begin
      hash = {}
      connection = ActiveRecord::Base.connection
      connection.select_all(CLAIM_SUBJECT_SQL).each do |row|
        hash[row["id"]] ||= []
        hash[row["id"]] << row["subject"]
      end
      ccc.write "CLAIM-SUBJECTS", hash
    end
  end

  def reset_claim_counts
    claim_count_cache.reset
  end
end

format :json do
  view :content, cache: :never do
    result = super()
    result_card_value = result[:card] && result[:card][:value]
    result_card_value.reject!(&:nil?) if result_card_value.is_a? Array
    result
  end

  view :id_atom, cache: :never do |_args|
    if !params["start"] || (params["start"] && (start = params["start"].to_i) &&
       card.updated_at.strftime("%Y%m%d%H%M%S").to_i >= start)
      h = _render_atom
      h[:id] = card.id  if card.id
      h
    end
  end
end
