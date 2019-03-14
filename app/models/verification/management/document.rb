class Verification::Management::Document
  include ActiveModel::Model
  include ActiveModel::Dates

  attr_accessor :document_type
  attr_accessor :document_number

  validates :document_type, :document_number, presence: true

  delegate :username, :email, to: :user, allow_nil: true

  def user
    @user = User.active.by_document(document_type, document_number).first
  end

  def user?
    user.present?
  end

  def in_census?
    if skip_verification?
      true
    else
      response = CensusCaller.new.call(Tenant.current, document_type, document_number,
        !user.nil? ? user.date_of_birth : nil)
      response.valid? && valid_age?(response)
    end
  end

  def valid_age?(response)
    if under_age?(response)
      errors.add(:age, true)
      false
    else
      true
    end
  end

  def under_age?(response)
    response.date_of_birth.blank? || Age.in_years(response.date_of_birth) < User.minimum_required_age
  end

  def verified?
    user? && (skip_verification? || user.level_three_verified?)
  end

  def verify
    user.update(verified_at: Time.current) if user?
  end

  def skip_verification?
    Setting["feature.user.skip_verification"].present?
  end

end
