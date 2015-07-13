format :html do
  def analysis_name
    @analysis_name ||= card.cardname.left
  end

  def data_item content, label, type=:default
    extra_class =
      case type
      when :highlight then 'btn btn-highlight'
      when :warning   then 'warning'
      else
        'btn btn-default'
      end
    content_tag :div, :class=>"contribution #{extra_class if extra_class}" do
      card_link analysis_name, :text=>%{
          <div class="content">
            #{content}
            <div class="name">#{label}</div>
          </div>
        }
    end
  end

  view :core do |args|
    article_card = Card.fetch "#{analysis_name}+article"
    claim_cnt = Card.fetch("#{analysis_name}+claim").cached_count
    source_cnt = Card.fetch("#{analysis_name}+sources").cached_count
    empty = glyphicon 'plus'
    data = []
    if claim_cnt == '0'
      data << ['<i class="fa fa-exclamation-circle"></i>', 'Need Claims', :warning]
      data << [ empty, 'Claims', :highlight ]
    else
      data << [(article_card ? nest(Card.fetch('venn icon'), :view=>:content,:size=>:small) : empty), 'Article', (:highlight if !article_card)]
      data << [ claim_cnt, 'Claims']
    end
    data << [(source_cnt == '0' ? empty : source_cnt), 'Sources', (:highlight if source_cnt=='0')]

    data.reverse.map {|opts| data_item(*opts)}.join "\n"  # reverse because of float:right
  end
end
