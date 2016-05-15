# -*- encoding : utf-8 -*-

class AddCsoMetrics < Card::Migration
  # I'm using the row number from the spreadsheet for an easier translation
  # number => {{metric}}
  # $number => {{metric | year: 2005}}
  # #number => {{metric | year: 2006..0}}
  DATA =
    {
      70 => ['Maximum Allowable OECD CO2 Emissions', nil],
      71 => ['Maximum Allowable OECD CO2 Emissions - Ratio to Baseline', nil],
      72 => ['GDP of OECD', nil],

      75 => ['Value-added Contributions to GDP (C2GDP)', nil],
      76 => ['Annual CO2 Emissions', nil],
      77 => ['Gross Revenue', nil],

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
    add_researched_metrics
    add_formula_metrics
  end

  def add_researched_metrics
    [75, 76, 77].each do |row|
      name = "#{CSO}+#{DATA[row][0]}"
      next if Card.exist? name
      Card::Metric.create name: "#{CSO}+#{DATA[row][0]}",
                          type: :researched
    end
  end

  def add_formula_metrics
    [85, 86, 88, 89, 94, 95, 91, 92, 80, 81, 82, 83].each do |row|
      name, raw_formula = DATA[row]
      Card::Metric.create name: "#{CSO}+#{name}",
                          type: :formula,
                          formula: formula(raw_formula)
    end
  end

  def formula raw_formula
    raw_formula.gsub(/(?<year_symbol>[#$])?(?<number>\d+)/) do
      metric_index = $~[:number].to_i
      if metric_index < 70 || metric_index > 95
        $~[:number]
      else
        year_expr =
          case $~[:year_symbol]
          when '#' then '|year: 2006..0'
          when '$' then '|year: 2005'
          else ''
          end
        input_name = DATA[metric_index][0]
        nest = format '{{%s+%s%s}}', CSO, input_name, year_expr
        $~[:year_symbol] == '#' ? "Sum[#{nest}]" : nest
      end
    end
  end
end
