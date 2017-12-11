format do
  view :missing do
    nest Card["missing image"], view: :core, size: voo.size
  end
end

format :html do
  view :core do
    handle_source do |source|
      if source.blank? || source == "missing"
        render_missing
      else
        image_tag source
      end
    end
  end

  view :missing do
    wrap_missing do
      nest Card["missing image"], view: :core, size: voo.size
    end
  end

  def wrap_missing
    @denied_view == :core ? yield : wrap(false) { yield }
  end
end
