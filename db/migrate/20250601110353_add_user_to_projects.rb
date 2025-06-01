class AddUserToProjects < ActiveRecord::Migration[8.0]
  def change
    # First add the column as nullable
    add_reference :projects, :user, null: true, foreign_key: true

    # Create a default user for existing projects if any exist
    reversible do |dir|
      dir.up do
        if Project.exists?
          default_user = User.find_or_create_by!(email_address: 'admin@example.com') do |user|
            user.password = 'password123'
            user.password_confirmation = 'password123'
          end

          # Assign existing projects to the default user
          Project.where(user_id: nil).update_all(user_id: default_user.id)
        end

        # Now make the column NOT NULL
        change_column_null :projects, :user_id, false
      end

      dir.down do
        # When rolling back, make the column nullable first
        change_column_null :projects, :user_id, true
      end
    end
  end
end
