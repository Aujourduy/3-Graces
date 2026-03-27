class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings do |t|
      t.text :claude_global_instructions

      t.timestamps
    end
  end
end
