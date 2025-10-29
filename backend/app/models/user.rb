class User < ApplicationRecord
  has_many :organized_events, class_name: "Event", foreign_key: :organizer_id, dependent: :destroy
  has_many :invitations, foreign_key: :invitee_id, dependent: :nullify

  validates :name, presence: true, length: { maximum: 120 }
  validates :name, uniqueness: { case_sensitive: false }

  before_validation :normalize_name

  def normalize_name
    self.name = name.to_s.strip.squish
  end

  def claim_matching_invitations!
    Invitation.where(invitee_id: nil)
              .where("lower(invitee_name) = ?", name.downcase)
              .find_each { |invitation| invitation.update(invitee: self) }
  end

  def location_hash
    return nil unless location_permission && location_latitude.present? && location_longitude.present?

    {
      latitude: location_latitude,
      longitude: location_longitude
    }
  end

  def to_api
    {
      id: id,
      name: name,
      location_permission: location_permission,
      location: location_hash
    }
  end
end