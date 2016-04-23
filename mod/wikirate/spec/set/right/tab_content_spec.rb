describe Card::Set::Right::TabContent do
  before do
    login_as 'joe_user'
    @company = get_a_sample_company
    @key = @company.cardname.url_key
  end
  describe 'core view' do
    it 'renders according to the tab' do
      Card::Env.params['tab'] = 'topic'
      company_tab_content = @company.fetch trait: :tab_content
      html = company_tab_content.format.render_core
      expect(html).to have_tag('div', with: { id: "#{@key}+topic_page" })
      Card::Env.params['tab'] = 'note'
      html = company_tab_content.format.render_core
      expect(html).to have_tag('div', with: { id: "#{@key}+note_page" })
    end
    it 'renders empty if tab not expected' do
      Card::Env.params['tab'] = 'wagn'
      company_tab_content = @company.fetch trait: :tab_content
      html = company_tab_content.format.render_core
      expect(html).to eq('')
    end
    it 'redners metric tab by default' do
      company_tab_content = @company.fetch trait: :tab_content
      html = company_tab_content.format.render_core
      expect(html).to have_tag('div', with: { id: "#{@key}+metric_page" })
    end
  end
end
