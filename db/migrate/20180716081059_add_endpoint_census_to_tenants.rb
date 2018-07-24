class AddEndpointCensusToTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :endpoint_census, :string
  end
end
