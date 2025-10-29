class CreatePreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :preferences do |t|
      t.references :invitation, null: false, foreign_key: true
      t.jsonb :available_times, null: false, default: []
      t.jsonb :activities, null: false, default: []
      t.integer :budget_min
      t.integer :budget_max
      t.text :ideas
      t.decimal :location_latitude, precision: 10, scale: 6
      t.decimal :location_longitude, precision: 10, scale: 6
      t.datetime :submitted_at

      t.timestamps
    end
  end
end
