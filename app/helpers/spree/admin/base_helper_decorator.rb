Spree::BaseHelper.class_eval do
  def selected?(current_type, tab_type)
    current_type == tab_type
  end

  def form_action(report, report_type)
    report ? admin_insight_path(id: @report_name, type: report_type) : 'javascript:void(0)'
  end

  def page_selector_options
    [5, 10, 15, 30, 45, 60]
  end

end
