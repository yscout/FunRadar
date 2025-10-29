class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.boolean :location_permission, null: false, default: false
      t.decimal :location_latitude, precision: 10, scale: 6
      t.decimal :location_longitude, precision: 10, scale: 6
      t.datetime :last_signed_in_at
      t.timestamps
    end
    add_index :users, "lower(name)", unique: true, name: "index_users_on_lower_name"
  end
end
