format do
  view :missing, cache: :never do
    nest Card["missing image"], view: :core, size: voo.size
  end
end

format :html do
  view :missing, cache: :never do
    wrap_missing do
      nest Card["missing image"], view: :core, size: voo.size
    end
  end

  def wrap_missing
    @denied_view == :core ? yield : wrap(false) { yield }
  end
end
