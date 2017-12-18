require 'octokit'

Octokit.auto_paginate = true
client = Octokit::Client.new :access_token => ENV["OAUTH_ACCESS_TOKEN"]
user = gets.chomp
client.repositories(user).each do |repository|
  full_name = repository[:full_name]
  has_push_access = repository[:permissions][:push]

  access_type = if has_push_access
                  "write"
                else
                  "read-only"
                end

  puts "#{client.user.name} has #{access_type} access to #{full_name}."
end