
format :html do
  def formgroup title, content, opts={}
    return super(title, content, opts) unless opts.delete(:oneline)
    wrap_with :div, formgroup_div_args(opts[:class]).css_merge(class: "row") do
      %(
        <div class='col-md-3'>
          #{form.label(opts[:editor] || :content, title)}
        </div>
        <div class='col-md-9'>
          #{editor_wrap(opts[:editor]) { content }}
          #{formgroup_help_text opts[:help]}
        </div>
      )
    end
  end
end
