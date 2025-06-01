# Homey Task - Project Management System

A modern Rails application for collaborative project management with real-time communication features. Built with Rails 8, Hotwire, and Tailwind CSS.

## Features

- **User Authentication**: Secure user registration and session management with password reset functionality
- **Project Management**: Create and manage projects with multiple status levels (pending, in_progress, completed, on_hold, cancelled)
- **Team Collaboration**: Add team members to projects with role-based access (member/admin)
- **Real-time Communication**: Live comments and status updates using Hotwire Turbo Streams
- **Project Timeline**: Track project status changes and conversation history
- **Responsive Design**: Modern UI built with Tailwind CSS

## Tech Stack

- **Ruby**: 3.2.1
- **Rails**: 8.0.2
- **Database**: SQLite3 (development/test), configurable for production
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS
- **Authentication**: bcrypt with secure password handling
- **Real-time Features**: Turbo Streams for live updates
- **Testing**: RSpec with FactoryBot, Capybara for system tests
- **Code Quality**: RuboCop, Brakeman for security analysis

## System Requirements

- Ruby 3.2.1
- Node.js (for asset compilation)
- SQLite3
- Git

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd homey_task
bin/setup
```

### 2. Database Setup

```bash
# Create and migrate the database
bin/rails db:create db:migrate

# Seed with sample data (optional)
bin/rails db:seed
```

### 3. Development Server

```bash
# Start the development server with asset watching
bin/dev
```

This starts both the Rails server (port 3000) and Tailwind CSS watcher.

Alternatively, start services separately:
```bash
# Rails server only
bin/rails server

# Tailwind CSS watcher (in another terminal)
bin/rails tailwindcss:watch
```

## Sample Users (after seeding)

- alice@example.com / password123
- bob@example.com / password123
- carol@example.com / password123
- david@example.com / password123
- eva@example.com / password123
- frank@example.com / password123

## Application Structure

### Models

- **User**: Authentication and user management
- **Project**: Core project entity with status tracking
- **ProjectMembership**: Many-to-many relationship between users and projects
- **Comment**: Real-time project communication
- **StatusChange**: Audit trail for project status updates
- **Session**: User session management

### Key Features

- **Project Access Control**: Users can only access projects they own or are members of
- **Real-time Updates**: Comments appear instantly using Turbo Streams
- **Status Tracking**: Complete audit trail of project status changes
- **Team Management**: Add/remove team members with different roles

## Testing

Run the test suite:

```bash
# Run all tests
bin/rails spec

# Run specific test types
bin/rails spec:models
bin/rails spec:controllers
bin/rails spec:system
```

## Code Quality

```bash
# Run RuboCop for style checking
bin/rubocop

# Run Brakeman for security analysis
bin/brakeman
```

## Deployment

### Docker Deployment

```bash
# Build the Docker image
docker build -t homey_task .

# Run the container
docker run -d -p 80:80 -e RAILS_MASTER_KEY=<your-master-key> --name homey_task homey_task
```

### Production Setup

1. Set environment variables:
   - `RAILS_MASTER_KEY` or `config/master.key`
   - Database configuration in `config/database.yml`

2. Asset precompilation:
   ```bash
   bin/rails assets:precompile
   ```

3. Database setup:
   ```bash
   bin/rails db:create db:migrate
   ```

## Configuration

### Environment Variables

- `RAILS_ENV`: Application environment (development/test/production)
- `DATABASE_URL`: Database connection string for production
- `RAILS_MASTER_KEY`: For encrypted credentials

### Key Configuration Files

- `config/database.yml`: Database configuration
- `config/routes.rb`: Application routes
- `Procfile.dev`: Development process configuration
- `config/deploy.yml`: Kamal deployment configuration

## Development Workflow

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Run Tests**
   ```bash
   bin/rails spec
   ```

3. **Check Code Quality**
   ```bash
   bin/rubocop
   bin/brakeman
   ```

4. **Commit and Push**
   ```bash
   git add .
   git commit -m "Add your feature"
   git push origin feature/your-feature-name
   ```

## API Endpoints

- `GET /` - Project dashboard
- `GET /projects/:id` - Project details with real-time comments
- `POST /projects/:id/comments` - Add comment to project
- `PATCH /projects/:id/update_status` - Update project status
- `POST /session` - User login
- `POST /registrations` - User registration
- `GET|POST /passwords` - Password reset

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Support

For questions or issues, please create an issue in the GitHub repository.
