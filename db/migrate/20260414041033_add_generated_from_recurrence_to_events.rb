class AddGeneratedFromRecurrenceToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :generated_from_recurrence, :boolean, default: false, null: false
  end
end
