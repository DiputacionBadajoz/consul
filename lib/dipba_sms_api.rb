require 'open-uri'

class DipbaSMSApi
  attr_accessor :client

  def initialize(tenant = Tenant.current)
    @tenant = tenant
    @client = Faraday.new(:ssl => {:verify => false})
  end

  def url
    return "" unless end_point_available?
    open(Rails.application.secrets.sms_end_point).base_uri.to_s
  end

  def sms_deliver(phone, code)
    return stubbed_response unless end_point_available?

    response = client.post "#{url}/#{Rails.application.secrets.sms_username}", request(phone, code)
    success?(response)
  end

  def request(phone, code)
    { api_key:  Rails.application.secrets.sms_password,
      destinatario: phone,
      mensaje: "Clave para verificarte: #{code}. #{@tenant.title}"}
  end

  def success?(response)
    response.status == "200"
  end

  def end_point_available?
    Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
  end

end
