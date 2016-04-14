describe Card::Set::TypePlusRight::Source::File::Import do
  before do
    login_as 'joe_user'
    test_csv = File.open "#{Rails.root}/mod/wikirate_source/spec/set/" \
                         'type_plus_right/source/import_test.csv'
    @source = create_source file: test_csv

    @metric_name = 'Access to Nutrition Index+Marketing Score'
    @amazon_value = "#{@metric_name}+Amazon.com, Inc.+2015"
    @apple_value  = "#{@metric_name}+Apple Inc.+2015"
    @sony_value   = "#{@metric_name}+Sony Corporation+2015"

    Card::Env.params['is_metric_import_update'] = 'true'
  end

  describe 'while adding metric value' do
    it 'shows errors while params do not fit' do
      source_file = @source.fetch trait: :file
      source_file.update_attributes subcards: {
        "#{@source.name}+#{Card[:metric].name}" => {
          content: "[[#{@metric_name}]]",
          type_id: Card::PointerID
        }
      }
      expect(source_file.errors).to have_key(:content)
      expect(source_file.errors[:content]).to include('Please give a Year.')

      # as local cache will be cleaned after every request,
      # this reset local is pretending last request is done
      Card::Cache.reset_soft
      source_file.update_attributes subcards: {
        "#{@source.name}+#{Card[:year].name}" => {
          content: '[[2015]]', type_id: Card::PointerID
        }
      }

      expect(source_file.errors).to have_key(:content)
      expect(source_file.errors[:content]).to include('Please give a Metric.')
    end

    it 'adds correct metric values' do
      Card::Env.params[:metric_values] =
        [{ company: 'Amazon.com, Inc.', value: '9' },
         { company: 'Apple Inc.',       value: '62' }
        ]
      source_file = @source.fetch trait: :file
      source_file.update_attributes subcards: {
        "#{@source.name}+#{Card[:metric].name}" => {
          content: "[[#{@metric_name}]]",
          type_id: Card::PointerID
        },
        "#{@source.name}+#{Card[:year].name}" => {
          content: '[[2015]]', type_id: Card::PointerID
        }
      }

      expect(Card.exists?(@amazon_value)).to be true
      expect(Card.exists?(@apple_value)).to be true

      expect(Card["#{@amazon_value}+value"].content).to eq('9')
      expect(Card["#{@apple_value}+value"].content).to eq('62')
    end

    context 'company correction name is filled' do
      it 'should use the correction name as company names' do
        Card::Env.params[:metric_values] = [
          { company: 'Amazon.com, Inc.', value: '9'  },
          { company: 'Apple Inc.',       value: '62' },
          { company: 'Sony Corporation', value: '13' }
        ]
        Card::Env.params[:corrected_company_name] = {
          'Amazon.com, Inc.' => 'Apple Inc.',
          'Apple Inc.'       => 'Sony Corporation',
          'Sony Corporation' => 'Amazon.com, Inc.'
        }
        source_file = @source.fetch trait: :file
        source_file.update_attributes subcards: {
          "#{@source.name}+#{Card[:metric].name}" => {
            content: "[[#{@metric_name}]]",
            type_id: Card::PointerID
          },
          "#{@source.name}+#{Card[:year].name}" => {
            content: '[[2015]]', type_id: Card::PointerID
          }
        }

        expect(Card.exists?(@amazon_value)).to be true
        expect(Card.exists?(@apple_value)).to be true
        expect(Card.exists?(@sony_value)).to be true

        expect(Card["#{@amazon_value}+value"].content).to eq('13')
        expect(Card["#{@apple_value}+value"].content).to eq('9')
        expect(Card["#{@sony_value}+value"].content).to eq('62')

        expect(amazon_2015_metric_value_card.content).to eq('13')
        expect(apple_2015_metric_value_card.content).to eq('9')
        expect(sony_2015_metric_value_card.content).to eq('62')
      end

      context "input company doesn't exist in wikirate" do
        it 'should create company and the value' do
          Card::Env.params[:metric_values] =
            [{ company: 'Cambridge', value: '800' }]
          Card::Env.params[:corrected_company_name] =
            { 'Cambridge' => 'Cambridge University' }

          source_file = @source.fetch trait: :file
          source_file.update_attributes(
            subcards: {
              "#{@source.name}+#{Card[:metric].name}" => {
                content: "[[#{@metric_name}]]",
                type_id: Card::PointerID
              },
              "#{@source.name}+#{Card[:year].name}" => {
                content: '[[2015]]',
                type_id: Card::PointerID
              }
            }
          )

          expect(Card.exists?('Cambridge University')).to be true
          expect(
            Card.exists?("#{@metric_name}+Cambridge University+2015")
          ).to be true

          cambridge_2015_metric_value_card =
            Card["#{@metric_name}+Cambridge University+2015+value"]
          expect(cambridge_2015_metric_value_card.content).to eq('800')
        end
      end
    end

    context 'company correction name is empty' do
      context 'non-matching case' do
        it 'should create company and the value' do
          Card::Env.params[:metric_values] =
            [{ company: 'Cambridge', value: '800' }]

          source_file = @source.fetch trait: :file
          source_file.update_attributes(
            subcards: {
              "#{@source.name}+#{Card[:metric].name}" => {
                content: "[[#{@metric_name}]]",
                type_id: Card::PointerID
              },
              "#{@source.name}+#{Card[:year].name}" => {
                content: '[[2015]]',
                type_id: Card::PointerID
              }
            }
          )
          expect(Card.exists?('Cambridge')).to be true
          expect(Card.exists?("#{@metric_name}+Cambridge+2015")).to be true
          cambridge_2015_metric_value_card =
            Card["#{@metric_name}+Cambridge+2015+value"]
          expect(cambridge_2015_metric_value_card.content).to eq('800')
        end
      end
    end

    context 'metric value exists' do
      it 'updates metric values' do
        Card::Env.params[:metric_values] =
          [{ company: 'Amazon.com, Inc.', value: '9' }]

        source_file = @source.fetch trait: :file
        source_file.update_attributes(
          subcards: {
            "#{@source.name}+#{Card[:metric].name}" => {
              content: "[[#{@metric_name}]]",
              type_id: Card::PointerID
            },
            "#{@source.name}+#{Card[:year].name}" => {
              content: '[[2015]]',
              type_id: Card::PointerID
            }
          }
        )

        expect(Card.exists?("#{@metric_name}+Amazon.com, Inc.+2015")).to be true

        amazon_2015_metric_value_card =
          Card["#{@metric_name}+Amazon.com, Inc.+2015+value"]
        expect(amazon_2015_metric_value_card.content).to eq('9')

        Card::Env.params[:metric_values] =
          [{ company: 'Amazon.com, Inc.', value: '9' }]
        source_file.update_attributes(
          subcards: {
            "#{@source.name}+#{Card[:metric].name}" => {
              content: "[[#{@metric_name}]]",
              type_id: Card::PointerID
            },
            "#{@source.name}+#{Card[:year].name}" => {
              content: '[[2015]]',
              type_id: Card::PointerID
            }
          }
        )
        expect(amazon_2015_metric_value_card.content).to eq('999')
      end
    end
  end

  describe 'updating metric values' do
    it 'updates correct metric values' do
      test_csv = File.open("#{Rails.root}/mod/wikirate_source/" \
                           'spec/set/type_plus_right/source/import_test2.csv')
      new_source = create_source file: test_csv

      Card::Env.params[:metric_values] =
        [{ company: 'Amazon.com, Inc.', value: '9'  },
         { company: 'Apple Inc.',       value: '62' }]
      source_file = @source.fetch trait: :file
      source_file.update_attributes(
        subcards: {
          "#{@source.name}+#{Card[:metric].name}" => {
            content: "[[#{@metric_name}]]",
            type_id: Card::PointerID
          },
          "#{@source.name}+#{Card[:year].name}" => {
            content: '[[2015]]',
            type_id: Card::PointerID
          }
        }
      )

      expect(Card.exists?(@amazon_value)).to be true
      expect(Card.exists?(@apple_value)).to be true

      expect(Card["#{@amazon_value}+value"].content).to eq('9')
      expect(Card["#{@apple_value}+value"].content).to eq('62')

      Card::Env.params[:metric_values] =
        [{ company: 'Amazon.com, Inc.', value: '369' },
         { company: 'Apple Inc.',       value: '689' }]

      source_file = new_source.fetch trait: :file
      source_file.update_attributes(
        subcards: {
          "#{new_source.name}+#{Card[:metric].name}" => {
            content: "[[#{@metric_name}]]",
            type_id: Card::PointerID
          },
          "#{new_source.name}+#{Card[:year].name}" => {
            content: '[[2015]]',
            type_id: Card::PointerID
          }
        }
      )

      expect(source_file.errors).to be_empty
      expect(Card.exists?("#{@amazon_value}+link")).to be false
      expect(Card.exists?("#{@apple_value}+link")).to be false

      expect(Card["#{@amazon_value}+value"].content).to eq('369')
      expect(Card["#{@apple_value}+value"].content).to eq('689')
    end
  end

  describe 'while rendering import view' do
    it 'shows field correctly' do
      source_file_card = @source.fetch trait: :file
      html = source_file_card.format.render_import

      expect(html).to have_tag('div',
                               with: { card_name: "#{@source.name}+Metric" }) do
        with_tag 'input', with: {
          class: 'card-content form-control',
          id: "card_subcards_#{@source.name}_Metric_content"
        }
      end

      expect(html).to have_tag('div',
                               with: { card_name: "#{@source.name}+Year" }) do
        with_tag 'input', with: {
          class: 'card-content form-control',
          id: "card_subcards_#{@source.name}_Year_content"
        }
      end

      expect(html).to have_tag('input',
                               with: { id: 'is_metric_import_update',
                                       value: 'true',
                                       type: 'hidden' })

      expect(html).to have_tag('table',
                               with: { class: 'import_table' }) do
        with_tag 'tr' do
          with_tag 'input',
                   with: { type: 'checkbox',
                           value: '43',
                           id: 'metric_values_Cambridge_' }
          with_tag 'td', text: 'Cambridge'
          with_tag 'td', text: 'none'
          with_tag 'td' do
            with_tag 'input', with: { type: 'text',
                                      name: 'corrected_company_name[Cambridge]'
                                    }
          end
        end
        with_tag 'tr' do
          with_tag 'input',
                   with: { checked: 'checked',
                           type: 'checkbox',
                           value: '9',
                           id: 'metric_values_Amazon.com__Inc._' }
          with_tag 'td', text: 'Amazon.com, Inc.'
          with_tag 'td', text: 'amazon.com'
          with_tag 'td', text: 'alias'
          with_tag 'td' do
            with_tag 'input', with: {
              type: 'text', name: 'corrected_company_name[Amazon.com, Inc.]'
            }
          end
        end
        with_tag 'tr' do
          with_tag 'input', with: { checked: 'checked',
                                    type: 'checkbox',
                                    value: '62',
                                    id: 'metric_values_Apple_Inc._' }
          with_tag 'td', text: 'Apple Inc.'
          with_tag 'td', text: 'exact'
        end
        with_tag 'tr' do
          with_tag 'input', with: { checked: 'checked',
                                    type: 'checkbox',
                                    value: '33',
                                    id: 'metric_values_Sony_Corporation_' }
          with_tag 'td', text: 'Sony Corporation'
          with_tag 'td', text: 'Sony C'
          with_tag 'td', text: 'partial'
          with_tag 'td' do
            with_tag 'input', with: {
              type: 'text', name: 'corrected_company_name[Sony Corporation]'
            }
          end
        end
      end
    end
  end
end
