class ApplicationSerializer < ActiveModel::Serializer

  # Serializes keys into camelcase
  # https://github.com/rails-api/active_model_serializers/issues/398#issuecomment-46790224
  def attributes
    super.map { |k, v| [ k.to_s.camelize(:lower).to_sym, v ] }.to_h
  end
end