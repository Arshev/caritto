class Reservation < ApplicationRecord

  enum status: {Waiting: 0, Approved: 1, Declined: 2}
after_create_commit :create_notification


  belongs_to :user
  belongs_to :car

  # def approved_reservations
  #   self.where(status: 1)
  # end
  #
  # scope: approved_reservations -> (status) { where("status = ?", status) }

  scope :current_week_revenue, -> (user) {
    joins(:car)
    .where("cars.user_id = ? AND reservations.updated_at >= ? AND reservations.status = ?", user.id, 1.week.ago, 1)
    .order(updated_at: :asc)
  }

  private

    def create_notification
      type = self.car.Instant? ? "New Booking" : "New Request"
      guest = User.find(self.user_id)

      Notification.create(content: "#{type} from #{guest.fullname}", user_id: self.car.user_id)
    end
end
