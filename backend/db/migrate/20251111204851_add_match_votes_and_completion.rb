class AddMatchVotesAndCompletion < ActiveRecord::Migration[8.1]
  def change
    create_table :match_votes do |t|
      t.references :event, null: false, foreign_key: true
      t.references :invitation, null: false, foreign_key: true
      t.string :match_id, null: false
      t.integer :score, null: false
      t.timestamps
    end

    add_index :match_votes, [:event_id, :match_id]
    add_index :match_votes, [:invitation_id, :match_id], unique: true

    add_column :events, :final_match, :jsonb, default: {}, null: false
    add_column :events, :completed_at, :datetime
  end
end