class Car < ApplicationRecord

  enum instant: {Request: 0, Instant: 1}

  belongs_to :user
  has_many :photos, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :guest_reviews, dependent: :destroy
  has_many :calendars, dependent: :destroy

  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  validates :car_type, presence: true
  validates :fuel, presence: true
  validates :people_capacity, presence: true
  validates :transmission, presence: true
  validates :year, presence: true
  validates :engine_capacity, presence: true
  validates :number_doors, presence: true

  def cover_photo(size)
    if self.photos.length > 0
      self.photos[0].image.url(size)
    else
      "blank.jpg"
    end
  end

  def average_rating
    guest_reviews.count == 0 ? 0 : guest_reviews.average(:star).round(2).to_i
  end
end
