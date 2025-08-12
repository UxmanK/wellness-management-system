class AddNotesAndStatusToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :notes, :text
    add_column :appointments, :status, :string
  end
end
