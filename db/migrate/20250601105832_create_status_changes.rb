class CreateStatusChanges < ActiveRecord::Migration[8.0]
  def change
    create_table :status_changes do |t|
      t.references :project, null: false, foreign_key: true
      t.string :from_status
      t.string :to_status
      t.string :changed_by

      t.timestamps
    end
  end
end
