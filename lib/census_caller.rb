class CensusCaller

  def call(tenant, document_type, document_number, birth_date)
    response = DipbaCensusApi.new(tenant).call(document_type, document_number, birth_date)
    response = LocalCensus.new.call(document_type, document_number) unless response.valid?

    response
  end
end
