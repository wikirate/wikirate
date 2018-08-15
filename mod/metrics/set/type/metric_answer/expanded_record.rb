# TODO: nearly everything in here should be associated with _records_, not _answers_.
#
# These are the full record views seen when expanding an answer on a company
# or record page.

format :html do
  # used in metric value list on a metric page
  view :company_details_sidebar do
    voo.hide! :metric_info
    voo.hide! :metric_buttons
    details_sidebar :company
  end

  # used in metric values list on a company page
  view :metric_details_sidebar do
    voo.hide! :cited_source_links
    details_sidebar :metric do
      <<-HTML
        <div class="row clearfix">
          <div class="data-item text-center">
            <span class="btn label-metric">
              #{link_to_card card.metric_card, 'Metric Details'}
            </span>
          </div>
        </div>
        <hr>
      HTML
    end
  end

  def company_details_sidebar_header
    <<-HTML
      <div class="company-logo">
        #{link_to_card card.company_card,
                       nest(card.company_card.fetch(trait: :image)),
                       class: 'inherit-anchor'}
      </div>
      <div class="company-name">
        #{link_to_card card.company_card, nil, class: 'inherit-anchor'}
      </div>
    HTML
  end

  def metric_details_sidebar_header
    bs_layout do
      row 1, 11, class: "w-100" do
        column nest(card.metric_card.vote_count_card)
        column class: "p-0" do
          row metric_link, class: "name"
          row creator_info
        end
      end
    end
  end

  def metric_link
    link_to_card card.metric_card, card.metric_card.metric_title, class: "inherit-anchor"
  end

  def details_sidebar type
    wrap do
      <<-HTML
        <div class="#{type}-details-header">
          #{close_icon}
          <div class="row clearfix padding-top-20">
            #{send "#{type}_details_sidebar_header"}
          </div>
          <hr>
          #{send "#{type}_answers"}
          <br>
          #{yield if block_given?}
          #{discussion}
        </div>
      HTML
    end
  end

  def close_icon
    <<-HTML
        <div class="details-close-icon pull-right	">
          #{fa_icon 'times-circle', class: 'fa-2x'}
        </div>
    HTML
  end

  def discussion
    <<-HTML
        <div class="row discussion-container">
        <div class="row-icon">
          #{fa_icon :comment}
        </div>
        <div class="row-data">
              #{nest [card.record, discussion],
                     view: :titled,
                     title: 'Discussion',
                     show: 'commentbox'}
            </div>
        </div>
    HTML
  end

  def company_answers
    metric_values hide: [:metric_info, :metric_buttons]
  end

  def metric_answers
    metric_values hide: [:compact_header]
  end

  def metric_values args={}
    wrap_with :div, class: "row clearfix wiki" do
      nest(card.record_card, args.merge(view: :core,
                                        show: [:chart, :add_answer_redirect]))
    end
  end

  # TODO: use view of metric
  def creator_info
    output [designer_info, (scorer_info if card.metric_type == :score)]
  end

  def designer_info
    nest card.metric_card, view: :designer_info
  end

  def scorer_info
    nest card.metric_card.right, view: :scorer_info
  end
end
