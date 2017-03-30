module SourceHelper
  def create_page iUrl=nil, subcards={}
    create_page_with_sourcebox iUrl, subcards, "true"
  end

  def create_page_with_sourcebox iUrl=nil, subcards={}, sourcebox=nil
    Card::Auth.as_bot do
      url = iUrl || "http://www.google.com/?q=wikirateissocoolandawesomeyouknow"
      tmp_sourcebox = sourcebox || "true"
      Card::Env.params[:sourcebox] = tmp_sourcebox
      sourcepage = Card.create! type_id: Card::SourceID,
                                subcards: {
                                  "+Link" => { content: url }
                                }.merge(subcards)
      Card::Env.params[:sourcebox] = "false"

      sourcepage
    end
  end

  def create_link_source url
    create_source link: url
  end

  def create_source args
    Card.create source_args(args)
  end

  def source_args args
    res = {
      type_id: Card::SourceID,
      subcards: {
        "+Link" => {},
        "+File" => { type_id: Card::FileID },
        "+Text" => { type_id: Card::BasicID, content: "" }
      }
    }
    source_type_name = Card[:source_type].name
    add_source_type args, res, source_type_name
    res
  end

  def add_source_type args, res, source_type_name
    [:link, :file, :text].each do |key|
      next unless args[key]
      content_key = (key == :file ? :file : :content)
      res[:subcards]["+#{key.to_s.capitalize}"][content_key] = args[key]
      res[:subcards]["+#{source_type_name}"] = {}
      res[:subcards]["+#{source_type_name}"][:content] = "[[#{key}]]"
    end
  end
end
