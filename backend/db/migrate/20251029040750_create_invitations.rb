class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :invitee, foreign_key: { to_table: :users }
      t.string :invitee_name, null: false
      t.string :invitee_email
      t.integer :role, null: false, default: 1
      t.integer :status, null: false, default: 0
      t.uuid :access_token, null: false, default: "gen_random_uuid()"
      t.datetime :responded_at

      t.timestamps
    end

    add_index :invitations, :access_token, unique: true
    add_index :invitations, [:event_id, :invitee_id],
              unique: true,
              where: "invitee_id IS NOT NULL",
              name: "index_invitations_on_event_and_invitee"
  end
end
