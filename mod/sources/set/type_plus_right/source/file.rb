#include_set Abstract::UploadOrWeb
include_set Abstract::Tabs



def file_changed?
  !db_content_before_act.empty?
end

format :html do
  view :editor do
    haml :editor, file_editor: super()
#    static_tabs tab_hash(super()), "from your computer", :pills
  end

  def web_editor
    form.text_field :remote_file_url, class: "d0-card-content form-control",
                                      placeholder: "http://example.com"
  end

  # def tab_hash file_editor
  #   { "from your computer" => file_editor,
  #     "from the web" => "webiness" }
  # end
end
