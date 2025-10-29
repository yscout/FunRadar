class CreateActivitySuggestions < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_suggestions do |t|
      t.references :event, null: false, foreign_key: true
      t.jsonb :payload, null: false, default: []
      t.string :model_name

      t.timestamps
    end
  end
end
