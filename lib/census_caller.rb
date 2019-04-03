class CensusCaller

  def call(document_type, document_number, birth_date, tenant = Tenant.current)
    response = DipbaCensusApi.new(tenant).call(document_type, document_number, birth_date)
    response = LocalCensus.new.call(document_type, document_number) unless response.valid?

    response
  end
end
