class AddNomToProfessors < ActiveRecord::Migration[8.1]
  def change
    add_column :professors, :nom, :string
  end
end
