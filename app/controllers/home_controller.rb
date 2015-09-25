class HomeController < ApplicationController
  respond_to :html

  def index
    @origins = Ping.select(:origin).group(:origin)
      .order('origin ASC').map(&:origin)
  end
end