module Spree
  class TrendingSearchReport < Spree::Report
    HEADERS = [:searched_term, :occurrences]
    SEARCH_ATTRIBUTES = { start_date: :start_date, end_date: :end_date, keywords_cont: :keyword }

    def initialize(options)
      super
      @search_keywords_cont = @search[:keywords_cont].present? ? "%#{ @search[:keywords_cont] }%" : '%'
    end

    def generate(options = {})
      top_searches = SpreeReportify::ReportDb[:spree_page_events___page_events].
      where(page_events__activity: 'search').
      where(page_events__created_at: @start_date..@end_date).where(Sequel.ilike(:page_events__search_keywords, @search_keywords_cont)). #filter by params
      group(:searched_term).
      order(Sequel.desc(:occurrences))

      top_searches
    end

    def select_columns(dataset)
      dataset.select{[
        :search_keywords___searched_term,
        Sequel.as(count(:search_keywords), :occurrences)
      ]}
    end

    def chart_data
      top_searches = select_columns(generate)
      total_occurrences = SpreeReportify::ReportDb[top_searches].sum(:occurrences)
      SpreeReportify::ReportDb[top_searches].
      select{[
        Sequel.as((occurrences / total_occurrences) * 100, :y),
        Sequel.as(searched_term, :name)
      ]}.all.map { |obj| obj.merge({ y: obj[:y].to_f })} # to convert percentage into float value from string
    end

    def chart_json
      {
        chart: true,
        charts: [
          {
            name: 'trending-search',
            json: {
              chart: { type: 'pie' },
              title: { text: 'Trending Search Keywords' },
              tooltip: {
                  pointFormat: 'Search %: <b>{point.percentage:.1f}%</b>'
              },
              plotOptions: {
                  pie: {
                      allowPointSelect: true,
                      cursor: 'pointer',
                      dataLabels: {
                          enabled: false
                      },
                      showInLegend: true
                  }
              },
              series: [{
                  name: 'Hits',
                  data: chart_data
              }]
            }
          }
        ]
      }
    end

  end
end
