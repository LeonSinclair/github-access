require 'sinatra/auth/github'
require 'octokit'
require 'chartkick'


module Example
  class MyGraphApp < Sinatra::Base
    CLIENT_ID        = ENV['GH_GRAPH_CLIENT_ID']
    CLIENT_SECRET    = ENV['GH_GRAPH_SECRET_ID']
    
    enable :sessions

    attr_accessor :language_bytes, :language_obj, :languages
    set :github_options, {
      :scopes    => "repo",
      :secret    => CLIENT_SECRET,
      :client_id => CLIENT_ID
    }

    register Sinatra::Auth::Github

    get '/' do
      if !authenticated?
        authenticate!
      else
        octokit_client = Octokit::Client.new(:login => github_user.login, :access_token => github_user.token)
        repos = octokit_client.repositories
        @language_obj = {}
        repos.each do |repo|
          # sometimes language can be nil
          if repo.language
            if !@language_obj[repo.language]
              @language_obj[repo.language] = 1
            else
              @language_obj[repo.language] += 1
            end
          end
        end

        @languages = []
        @language_obj.each do |lang, count|
          @languages.push [:language => lang, :count => count]
        end
        puts languages

        @language_byte_count = []
        repos.each do |repo|
          repo_name = repo.name
          repo_langs = []
          begin
            repo_url = "#{github_user.login}/#{repo_name}"
            repo_langs = octokit_client.languages(repo_url)
          rescue Octokit::NotFound
            puts "Error retrieving languages for #{repo_url}"
          end
          if !repo_langs.empty?
            repo_langs.each do |lang, count|
              if !@language_obj[lang]
                @language_obj[lang] = count
              else
                @language_obj[lang] += count
              end
            end
          end
        end

        @language_obj.each do |lang, count|
          @language_byte_count.push :name => "#{lang} (#{count})", :count => count
        end

        erb :lang_freq
      end
    end
  end
end