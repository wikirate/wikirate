module SourceHelper
  def create_page url=nil, subcards={}
    create_page_with_sourcebox url, subcards, "true"
  end

  def create_page_with_sourcebox url=nil, subcards={}, sourcebox=nil
    Card::Auth.as_bot do
      url ||= "http://www.google.com/?q=wikirate"
      with_sourcebox sourcebox do
        Card.create! type_id: Card::SourceID,
                     subcards: {
                       "+Link" => { content: url }
                     }.merge(subcards)
      end
    end
  end

  def create_link_source url
    create_source link: url
  end

  def create_source args
    Card.create source_args(args)
  end

  def with_sourcebox sourcebox=nil
    Card::Env.params[:sourcebox] = sourcebox || "true"
    result = yield
    Card::Env.params[:sourcebox] = "false"
    result
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
