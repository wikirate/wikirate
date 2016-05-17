format :html do
  def google_analytics_head_javascript
    return unless (ga_key = Card.global_setting(:google_analytics_key))
    <<-JAVASCRIPT
        <script type="text/javascript">
          var _gaq = _gaq || [];
          _gaq.push(['_setAccount', '#{ga_key}']);
          _gaq.push(['_setPageGroup', '1', '#{root.card.type_name}']);
          _gaq.push(['_trackPageview']);
          (function() {
            var ga = document.createElement('script');
            ga.type = 'text/javascript';
            ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
          })();
        </script>
    JAVASCRIPT
  end

  view :raw do
    result = super()
    if request
      user_agent = request.user_agent
      if user_agent && (user_agent == "Facebot" ||
         user_agent.include?("facebookexternalhit/1.1"))
        fb_meta_card = Card.fetch("#{Env.params['id']}+facebook_meta")
        result += subformat(fb_meta_card)._render_core
      end
    end
    result
  end
end
