class RemoveModelNameFromActivitySuggestions < ActiveRecord::Migration[8.1]
  def change
    remove_column :activity_suggestions, :model_name, :string
  end
end
