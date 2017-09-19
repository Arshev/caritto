class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation, only: [:approve, :decline]
  def create
    car = Car.find(params[:car_id])

    if current_user == car.user
      flash[:alert] = "You cannot book your own property!"
    elsif current_user.stripe_id.blank?
      flash[:alert] = "Please update your payment method!"
      return redirect_to payment_method_path
    else
      start_date = Date.parse(reservation_params[:start_date])
      end_date = Date.parse(reservation_params[:end_date])
      days = (end_date - start_date).to_i + 1

      special_dates = car.calendars.where(
      "status = ? AND day BETWEEN ? AND ? AND price <> ?",
      0, start_date, end_date, car.price
      )

      @reservation = current_user.reservations.build(reservation_params)
      @reservation.car = car
      @reservation.price = car.price
      # @reservation.total = car.price * days
      #@reservation.save

      @reservation.total = car.price * (days - special_dates.count)
      special_dates.each do |date|
        @reservation.total += date.price
      end

      if @reservation.Waiting!
        if car.Request?
          flash[:notice] = "Request sent successfully!"
        else
          charge(car, @reservation)
        end
      else
        flash[:alert] = "Cannot make reservation!"
      end
    end
    redirect_to car
  end

  def your_trips
    @trips = current_user.reservations.order(start_date: :asc)
  end

  def your_reservations
    @cars = current_user.cars
  end

  def approve
    charge(@reservation.car, @reservation)
    redirect_to your_reservations_path, notice: "Approved..."
  end

  def decline
    @reservation.Approved!
    redirect_to your_reservations_path, notice: "Declined..."
  end

  private

    def send_sms(car, reservation)
      @client = Twilio::REST::Client.new
      @client.messages.create(
      from: '+18582958001',
      to: car.user.phone_number,
      body: "#{reservation.user.fullname} booked your '#{car.listing_name}'"
      )
    end

    def charge(car, reservation)
      if !reservation.user.stripe_id.blank?
        customer = Stripe::Customer.retrieve(reservation.user.stripe_id)
        charge = Stripe::Charge.create(
          :customer => customer.id,
          :amount => reservation.total * 100,
          :description => car.listing_name,
          :currency => "usd",
          :destination => {
            :amount => reservation.total * 80, # 80% of the total amount goes to the Host
            :account => car.user.merchant_id # Host's Stripe customer ID
          }
        )

        if charge
          reservation.Approved!
          send_sms(car, reservation) if car.user.setting.enable_sms
          ReservationMailer.send_email_to_guest(reservation.user, car).deliver_later if reservation.user.setting.enable_email
          flash[:notice] = "Reservation created successfully!"
        else
          reservation.Declined!
          flash[:alert] = "Cannot charge with this payment method!"
        end
      end
    rescue Stripe::CardError => e
      reservation.Declined!
      flash[:alert] = e.message
    end

    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    def reservation_params
      params.require(:reservation).permit(:start_date, :end_date)
    end
end
