class CreateShortUrls < ActiveRecord::Migration[8.1]
  def change
    create_table :short_urls do |t|
      t.string :slug, null: false
      t.string :target_url, null: false
      t.string :title

      t.timestamps
    end

    add_index :short_urls, :slug, unique: true
  end
end
