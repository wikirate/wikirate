# -*- encoding : utf-8 -*-

class AddCsoMetrics < Card::Migration
  # I'm using the row numbers from the spreadsheet for an easier translation
  # number => {{metric}}
  # $number => {{metric | year: 2005}}
  # #number => Sum[{{metric | year: 2006..0}}]
  DATA =
    {
      # Yearly Variables
      70 => ['Maximum Allowable OECD CO2 Emissions',
              [
                11475, 11550, 11625, 11701, 11776, 11851, 11743, 11634, 11525,
                11417, 1130
              ]
            ],
      71 => ['Maximum Allowable OECD CO2 Emissions - Ratio to Baseline',
              [
                1.0000, 1.0066, 1.0131, 1.0197, 1.0262, 1.0328, 1.0233, 1.0139,
                1.0044, 0.9949, 0.9855
              ]
            ],
      72 => ['GDP of OECD',
              [
                36447627200000, 39127218500000, 41294669500000, 42561395200000,
                41687612000000, 43446674000000, 45324766700000, 46576648200000,
                47694954500000, 49289717300000, 50521960232500
              ]
            ],

      # Research Metrics
      75 => ['Value-added Contributions to GDP (C2GDP)', nil],
      76 => ['Annual CO2 Emissions', nil],
      77 => ['Gross Revenue', nil],

      # Formula Metrics
      80 => ['Cumulative CO2 Emissions Context-Free Score', '86/89'],
      81 => ['Annual CO2 Emissions Context-Based Relative Score', '(76/75)/95'],
      82 => ['Annual CO2 Emissions Context-Based Absolute Score', '76/91'],
      83 => ['Cumulative CO2 Emissions Context-Based Absolute Score', '86/92'],

      85 => ['CO2 Emissions Relative to Gross Revenue', '76/77'],
      86 => ['Cumulative CO2 Emissions', '#76'],

      88 => ['Maximum Allowable Annual CO2 Emissions', '$76*71'],
      89 => ['Maximum Allowable Cumulative CO2 Emissions', '#88'],

      91 => ['Annual CO2 Emission Targets', '95*75'],
      92 => ['Cumulative CO2 Emission Targets', '#91'],

      94 => ['Maximum Allowable Annual CO2 Emissions per C2GDP', '$76/$75*71'],
      95 => ['Maximum Allowable Annual CO2 Emissions per C2GDP - ' \
             'Adjusted per OECD norm',
             '(70*1000000000)/' \
             '(($70*1000000000-$88)/($72-$75)*(72-75)*71+94*75)*94']
    }.freeze

  CSO = 'Center for Sustainable Organizations'.freeze

  def up
    create_yearly_variables
    create_researched_metrics
    create_formula_metrics
  end

  def create_yearly_variables
    [70, 71, 72].each do |row|
      Card::YearlyVariable.create_or_update name: input_name(row),
                                            values: DATA[row][1],
                                            first_year: 2005
    end
  end

  def create_researched_metrics
    [75, 76, 77].each do |row|
      next if Card.exists? input_name(row)
      Card::Metric.create name: input_name(row),
                          type: :researched
    end
  end

  def create_formula_metrics
    [85, 86, 88, 89, 94, 95, 91, 92, 80, 81, 82, 83].each do |row|
      name, raw_formula = DATA[row]
      Card::Metric.create name: input_name(name),
                          type: :formula,
                          formula: formula(raw_formula)
    end
  end

  def input_name row
    "#{CSO}+#{DATA[row][0]}"
  end

  def row_index? i
    DATA.keys.include? i
  end

  def formula raw_formula
    raw_formula.gsub(/(?<year_symbol>[#$])?(?<number>\d+)/) do
      input_row = $~[:number].to_i
      next $~[:number] unless row_index? input_row

      year_option, sum =
        case $~[:year_symbol]
        when '#' then '|year: 2006..0', true
        when '$' then '|year: 2005'
        else ''
        end
      nest = format '{{%s%s}}', input_name(metric_index), year_option
      sum ? "Sum[#{nest}]" : nest
    end
  end
end
