class CreateCompanyShares < ActiveRecord::Migration[7.0]
  def change
    create_table :company_shares do |t|
      t.integer :parent_id
      t.integer :child_id
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
