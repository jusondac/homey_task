# Clear existing data
puts "Clearing existing data..."
StatusChange.destroy_all
Comment.destroy_all
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

puts "Creating sample projects..."

# Project 1 - Alice's project
project1 = user1.projects.create!(
  name: "Website Redesign",
  description: "Complete overhaul of the company website with modern design and improved user experience.",
  status: "in_progress"
)

# Add some comments and status changes for project1
project1.comments.create!(
  content: "Initial wireframes have been completed and approved by the design team.",
  user: user1
)

project1.update_status!("on_hold", user2.email_address)

project1.comments.create!(
  content: "Waiting for content from the marketing team before we can proceed with the implementation.",
  user: user1
)

project1.update_status!("in_progress", user3.email_address)

project1.comments.create!(
  content: "Marketing has provided all the content. Development can now resume.",
  user: user3
)

# Project 2 - Bob's project
project2 = user2.projects.create!(
  name: "Mobile App Development",
  description: "Native mobile application for iOS and Android platforms.",
  status: "pending"
)

project2.comments.create!(
  content: "Requirements gathering phase is complete. Moving to design phase.",
  user: user2
)

project2.update_status!("in_progress", user2.email_address)

# Project 3 - Carol's project
project3 = user3.projects.create!(
  name: "Database Migration",
  description: "Migrate legacy database to new cloud infrastructure.",
  status: "completed"
)

project3.comments.create!(
  content: "Migration script has been tested in staging environment.",
  user: user3
)

project3.comments.create!(
  content: "All data validation tests passed successfully.",
  user: user1
)

project3.update_status!("completed", user3.email_address)

puts "Sample data created successfully!"
puts "Users: #{User.count}"
puts "Projects: #{Project.count}"
puts "Comments: #{Comment.count}"
puts "Status Changes: #{StatusChange.count}"
puts ""
puts "Sample user credentials:"
puts "alice@example.com / password123"
puts "bob@example.com / password123"
puts "carol@example.com / password123"
