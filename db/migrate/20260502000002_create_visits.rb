class CreateVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :visits do |t|
      t.references :short_url, null: false, foreign_key: true, index: true
      t.string :ip_address
      t.string :country
      t.string :city
      t.datetime :clicked_at, null: false
    end
  end
end
