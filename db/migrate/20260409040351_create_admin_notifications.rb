class CreateAdminNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_notifications do |t|
      t.string :title, null: false
      t.text :message
      t.string :category, null: false, default: "info"
      t.string :status, null: false, default: "non_lu"
      t.string :source
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    add_index :admin_notifications, :status
    add_index :admin_notifications, :category
  end
end
