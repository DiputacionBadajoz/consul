class AddCensusToTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :user_census, :string
    add_column :tenants, :password_census, :string
    add_column :tenants, :entity_census, :integer
    add_column :tenants, :organization_census, :integer
  end
end
