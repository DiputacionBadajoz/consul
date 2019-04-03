class DeviseMailer < Devise::Mailer
  helper :application, :settings
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'
  default from: "#{Setting['mailer_from_name']} <#{Setting['mailer_from_address']}>"
  default reply_to: "#{Setting['mailer_from_name']} <#{Setting['mailer_from_address']}>"

  def default_url_options
    dup = Rails.application.config.action_mailer.default_url_options
    if Apartment::Tenant.current != "public"
        tenant = Tenant.current
        unless tenant.nil?
          dup = { host: "#{tenant.subdomain}.#{tenant.server_name}" }
        end
    end

    return dup
  end

  def asset_host
    ah = Rails.application.config.action_mailer.asset_host
    if Apartment::Tenant.current != "public"
        tenant = Tenant.current
        unless tenant.nil?
          ah = "#{tenant.subdomain}.#{tenant.server_name}"
        end
    end

    return ah
  end

  protected

  def devise_mail(record, action, opts = {})
    I18n.with_locale record.locale do
      super(record, action, opts)
    end
  end
end
