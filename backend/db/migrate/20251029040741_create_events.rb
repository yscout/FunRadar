class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :organizer, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :notes
      t.integer :status, null: false, default: 0
      t.uuid :share_token, null: false, default: "gen_random_uuid()"
      t.jsonb :ai_summary, null: false, default: {}
      t.datetime :ai_generated_at
      t.timestamps
    end

    add_index :events, :share_token, unique: true
  end
end
