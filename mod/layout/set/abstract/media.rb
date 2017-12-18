format :html do
  def image_card
    @image_card ||= card.fetch(trait: :image)
  end

  def image_src opts
    return "" unless image_card
    nest(image_card, view: :source, size: opts[:size])
  end

  def image_alt
    image_card&.name
  end

  def text_with_image_args opts
    opts.reverse_merge! title: _render_title, text: "", src: image_src(opts),
                        alt: image_alt, size: :original
  end

  def text_with_image opts={}
    @image_card = Card.cardish(opts[:image]) if opts[:image]
    opts[:media_opts] = {} unless opts[:media_opts]
    text_with_image_args opts

    haml opts do
      <<-HAML.strip_heredoc
        .media{media_opts}
          .media-left.image-box.#{opts[:size]}
            %a{href: "#"}
              %img{class:"media-object #{opts[:size]}", src: src.html_safe, alt: alt}
          .media-body
            %h5.media-heading
              = title
            = text
      HAML
    end
  end

  def text_with_media _media, _title, _text, opts={}
    @image_card = Card.cardish(opts[:image]) if opts[:image]
    text_with_image_args opts

    haml opts do
      <<-HAML.strip_heredoc
        .media
          .media-left.image-box
            %a{href: "#"}
              %img{class:"media-object #{opts[:size]}", src: src, alt: alt}
          .media-body
            %h5.media-heading
              = title
            = text
      HAML
    end
  end
end
