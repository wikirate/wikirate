
format :html do
  def formgroup title, opts={}, &block
    if opts.delete :oneline
      oneline_formgroup title, opts, &block
    else
      super title, opts, &block
    end
  end

  def oneline_formgroup title, opts
    wrap_with :div, formgroup_div_args(opts[:class]).css_merge(class: "row") do
      [
        wrap_with(:div, class: "col-md-3") do
          form.label(opts[:input] || :content, title)
        end,
        wrap_with(:div, class: "col-md-9") do
          [editor_wrap(opts[:input]) { yield },
           formgroup_help_text(opts[:help])]
        end
      ]
    end
  end
end
