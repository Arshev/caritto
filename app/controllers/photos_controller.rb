class PhotosController < ApplicationController

  def create
    @car = Car.find(params[:car_id])

    if params[:image]
      params[:image].each do |img|
        @car.photos.create(image: img)
      end

      @photos = @car.photos
      redirect_back(fallback_location: request.referer, notice: "Saved...")
    end
  end

  def destroy
    @photo = Photo.find(params[:id])
    @car = @photo.car

    @photo.destroy
    @photos = Photo.where(car_id: @car.id)

    respond_to :js
  end
end
