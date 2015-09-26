class PaginatedSerializer < ActiveModel::ArraySerializer
  def initialize(object, options = {})
    meta_key = options[:meta_key] || :meta
    options[meta_key] ||= {}
    
    options[meta_key][:pagination] = {
      # total_pages: object.total_pages,
      # total_count: object.total_count,
      current_page: object.current_page,
      per_page: object.limit_value
    }.merge(options[meta_key][:pagination] || {})

    options[meta_key] = options[meta_key].map { |k, v| [ k.to_s.camelize(:lower).to_sym, v ] }.to_h
    super(object, options)
  end
end