
  def create_page iUrl=nil
      url = iUrl||'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    Card::Env.params[:sourcebox] = 'true'
    sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
    Card::Env.params[:sourcebox] = 'false'

    sourcepage
  end
def create_webpage url,sourcebox
  _url = url
  _url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow' if !url
  Card::Env.params[:sourcebox] = sourcebox
  sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> _url} }
end