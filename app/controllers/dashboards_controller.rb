class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @cars = current_user.cars
  end
end
