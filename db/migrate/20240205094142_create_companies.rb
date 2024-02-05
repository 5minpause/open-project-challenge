class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.references :owner, foreign_key: { to_table: 'users' }

      t.timestamps
    end
  end
end
