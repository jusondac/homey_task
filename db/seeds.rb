# Clear existing data
puts "Clearing existing data..."
StatusChange.destroy_all
Comment.destroy_all
ProjectMembership.destroy_all
Project.destroy_all
Session.destroy_all
User.destroy_all

# Create sample users
puts "Creating sample users..."

user1 = User.create!(
  email_address: "alice@example.com",
  password: "password123",
  password_confirmation: "password123"
)

user2 = User.create!(
  email_address: "bob@example.com",
  password: "password123",
  password_confirmation: "password123"
)

user3 = User.create!(
  email_address: "carol@example.com",
  password: "password123",
  password_confirmation: "password123"
)

user4 = User.create!(
  email_address: "david@example.com",
  password: "password123",
  password_confirmation: "password123"
)

user5 = User.create!(
  email_address: "eva@example.com",
  password: "password123",
  password_confirmation: "password123"
)

user6 = User.create!(
  email_address: "frank@example.com",
  password: "password123",
  password_confirmation: "password123"
)

puts "Creating sample projects..."

# Project 1 - Alice's project with multiple members
project1 = user1.projects.create!(
  name: "Website Redesign",
  description: "Complete overhaul of the company website with modern design and improved user experience.",
  status: "in_progress"
)

# Add members to project1
project1.project_memberships.create!(user: user2, role: "admin")
project1.project_memberships.create!(user: user3, role: "member")
project1.project_memberships.create!(user: user4, role: "member")

# Add some comments and status changes for project1
project1.comments.create!(
  content: "Initial wireframes have been completed and approved by the design team.",
  user: user1
)

project1.update_status!("on_hold", user2.display_name)

project1.comments.create!(
  content: "Waiting for content from the marketing team before we can proceed with the implementation.",
  user: user1
)

project1.comments.create!(
  content: "I can help with the backend API development once the designs are finalized.",
  user: user4
)

project1.update_status!("in_progress", user3.display_name)

project1.comments.create!(
  content: "Marketing has provided all the content. Development can now resume.",
  user: user3
)

project1.comments.create!(
  content: "Great! I'll start working on the responsive layouts.",
  user: user2
)

# Project 2 - Bob's project with members
project2 = user2.projects.create!(
  name: "Mobile App Development",
  description: "Native mobile application for iOS and Android platforms.",
  status: "pending"
)

# Add members to project2
project2.project_memberships.create!(user: user1, role: "member")
project2.project_memberships.create!(user: user5, role: "admin")

project2.comments.create!(
  content: "Requirements gathering phase is complete. Moving to design phase.",
  user: user2
)

project2.comments.create!(
  content: "I'll handle the UI/UX design for the mobile app.",
  user: user5
)

project2.update_status!("in_progress", user2.display_name)

project2.comments.create!(
  content: "Looking forward to working on this project. Let's schedule a kickoff meeting.",
  user: user1
)

# Project 3 - Carol's project
project3 = user3.projects.create!(
  name: "Database Migration",
  description: "Migrate legacy database to new cloud infrastructure.",
  status: "completed"
)

# Add members to project3
project3.project_memberships.create!(user: user6, role: "admin")
project3.project_memberships.create!(user: user4, role: "member")

project3.comments.create!(
  content: "Migration script has been tested in staging environment.",
  user: user3
)

project3.comments.create!(
  content: "All data validation tests passed successfully.",
  user: user6
)

project3.comments.create!(
  content: "Performance looks great on the new infrastructure!",
  user: user4
)

project3.update_status!("completed", user3.display_name)

project3.comments.create!(
  content: "Excellent work everyone! Migration completed successfully.",
  user: user3
)

# Project 4 - David's project
project4 = user4.projects.create!(
  name: "API Documentation",
  description: "Create comprehensive API documentation for all microservices.",
  status: "in_progress"
)

# Add members to project4
project4.project_memberships.create!(user: user1, role: "member")
project4.project_memberships.create!(user: user2, role: "member")
project4.project_memberships.create!(user: user5, role: "member")

project4.comments.create!(
  content: "Started working on the authentication endpoints documentation.",
  user: user4
)

project4.comments.create!(
  content: "I can help with the user management API docs.",
  user: user1
)

project4.comments.create!(
  content: "Let me know if you need help with the payment API documentation.",
  user: user2
)

puts "Sample data created successfully!"
puts "Users: #{User.count}"
puts "Projects: #{Project.count}"
puts "Project Memberships: #{ProjectMembership.count}"
puts "Comments: #{Comment.count}"
puts "Status Changes: #{StatusChange.count}"
puts ""
puts "Sample user credentials:"
puts "alice@example.com / password123"
puts "bob@example.com / password123"
puts "carol@example.com / password123"
puts "david@example.com / password123"
puts "eva@example.com / password123"
puts "frank@example.com / password123"
