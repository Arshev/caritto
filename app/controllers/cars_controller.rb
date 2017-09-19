class CarsController < ApplicationController

  before_action :set_car, except: [:index, :new, :create]
  before_action :authenticate_user!, except: [:show, :preload, :preview]
  before_action :is_authorised, only: [:listing, :pricing, :description, :photo_upload, :amenities, :location, :update]

  def index
    @cars = current_user.cars
  end

  def new
    @car = current_user.cars.build
  end

  def create
    if !current_user.is_active_host
      return redirect_to payout_method_path, alert: "Please Connect to Stripe Express first."
    end

    @car = current_user.cars.build(car_params)
    if @car.save
      redirect_to listing_car_path(@car), notice: "Saved..."
    else
      flash[:alert] = "Something went wrong..."
      render :new
    end
  end

  def destroy
    @car.destroy
    redirect_to cars_path, notice: "Deleted..."
  end

  def show
    @photos = @car.photos
    @guest_reviews = @car.guest_reviews
  end

  def listing
  end

  def pricing
  end

  def description
  end

  def photo_upload
    @photos = @car.photos
  end

  def amenities
  end

  def location
  end

  def update

    new_params = car_params
    new_params = car_params.merge(active: true) if is_ready_car

    if @car.update(new_params)
      flash[:notice] = "Saved..."
    else
      flash[:alert] = "Something went wrong..."
    end
    redirect_back(fallback_location: request.referer)
  end

  # --- Reservations ---
  def preload
    today = Date.today
    reservations = @car.reservations.where("(start_date >= ? OR end_date >= ?) AND status = ?", today, today, 1)
    unavailble_dates = @car.calendars.where("status = ? AND day > ?", 1, today)
    special_dates = @car.calendars.where("status = ? AND day > ? AND price <> ?", 0, today, @car.price)

    render json: {
      reservations: reservations,
      unavailble_dates: unavailble_dates,
      special_dates: special_dates
    }
  end

  def preview
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    output = {
      conflict: is_conflict(start_date, end_date, @car)
    }

    render json: output
  end

  private

  def is_conflict(start_date, end_date, car)
    check = car.reservations.where("(? < start_date AND end_date < ?) AND status = ?", start_date, end_date, 1)
    check_unavailble_in_calendar = car.calendars.where("day BETWEEN ? AND ? AND status = ?", start_date, end_date, 1).limit(1)

    check.size > 0 || check_unavailble_in_calendar.size > 0 ? true : false
  end

  def set_car
    @car = Car.find(params[:id])
  end

  def is_authorised
    redirect_to root_path, alert: "You don't have permission" unless current_user.id == @car.user_id
  end

  def is_ready_car
    !@car.active && !@car.price.blank? && !@car.car_name.blank? && !@car.photos.blank? && !@car.address.blank?
  end

  def car_params
    params.require(:car).permit(:car_type, :fuel, :mileage, :people_capacity, :transmission, :car_name, :description, :address, :year, :engine_capacity, :is_air, :body_color, :number_doors, :is_mp3, :navigator, :is_leather, :extra_field, :for_kids, :abroad, :smoking, :pets, :for_taxi,
    :price, :active, :instant)
  end
end
