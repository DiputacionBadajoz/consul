include DocumentParser
class DipbaCensusApi

  def initialize(tenant)
    @tenant = tenant
  end

  def call(document_type, document_number, birth_date)
    response = nil
    get_document_number_variants(document_type, document_number).each do |variant|
      response = Response.new(get_response_body(document_type, variant, birth_date))
      puts response
      return response if response.valid?
    end
    response
  end

  class Response
    def initialize(body)
      @body = body
    end

    def valid?
      data["s"]["res"]["exito"] == "-1"
    end

    def encontrado?
      data["s"]["par"]["encontrado"] == "1"
    end

    private

      def data
        @body[:servicio_response][:servicio_return]
      end
  end

  private

    def get_response_body(document_type, document_number, birth_date)
      if end_point_available?
        client.call(:servicio, message: request(document_type, document_number, birth_date)).body
      end
    end

    def client
      @client = Savon.client(wsdl: @tenant['endpoint_census'])
    end

    def request(document_type, document_number, birth_date)
      actualDate = DateTime.now.strftime('%Y%m%d%H%M%S')
      org = @tenant['organization_census']
      ent = @tenant['entity_census']
      user = @tenant['user_census']
      nonce = generate_nonce()
      token = generate_token(actualDate, nonce, 'llave1')
      document = Base64.encode64(document_number)
      password = Base64.encode64(Digest::SHA1.digest(@tenant['password_census'])).delete("\n").delete("\r")

      request = {
        ope: {
          apl: "PAD",
          tobj: "HAB",
          cmd: "CEN",
          ver: "2.0"
        },
        sec: {
          cli: "ACCEDE",
          org: org,
          ent: ent,
          usu: user,
          pwd: password,
          fecha: actualDate,
          nonce: nonce,
          token: token
        },
        par: {
          codigoTipoDocumento: document_type,
          documento: document,
          fechaNacimiento: birth_date
        }
      }
      request = request.to_xml(:root => "e")
      {"in0": request}
    end

    def end_point_available?
      #Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
      !(@tenant['endpoint_census'].nil? || @tenant['endpoint_census'].empty?)
    end

    def dni?(document_type)
      document_type.to_s == "1"
    end

    def encrypt_token(token)
      Base64.encode64(Digest::SHA512.digest(token)).delete("\n").delete("\r")
    end

    def generate_nonce()
      rand(999999999999999999)
    end

    def generate_token(actualDate, nonce, clave)
      token = nonce.to_s + actualDate + clave
      encrypt_token(token)
    end

end
