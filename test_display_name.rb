#!/usr/bin/env ruby

require_relative 'config/environment'

user = User.new(email_address: 'john.doe@example.com')
puts "Display name: '#{user.display_name}'"

user2 = User.new(email_address: 'test@example.com')
puts "Display name 2: '#{user2.display_name}'"
