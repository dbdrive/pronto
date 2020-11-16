require 'rugged'
require 'forwardable'
require 'rainbow'

require 'pronto/error'

require 'pronto/gem_names'

require 'pronto/logger'
require 'pronto/config_file'
require 'pronto/config'

require 'pronto/git/repository'
require 'pronto/git/patches'
require 'pronto/git/patch'
require 'pronto/git/line'

require 'pronto/plugin'
require 'pronto/message'
require 'pronto/comment'
require 'pronto/status'
require 'pronto/runner'
require 'pronto/runners'
require 'pronto/client'

require 'pronto/formatter/colorizable'
require 'pronto/formatter/base'
require 'pronto/formatter/text_formatter'
require 'pronto/formatter/json_formatter'
require 'pronto/formatter/git_formatter'
require 'pronto/formatter/commit_formatter'
require 'pronto/formatter/pull_request_formatter'
require 'pronto/formatter/checkstyle_formatter'
require 'pronto/formatter/null_formatter'
require 'pronto/formatter/formatter'

if ENV['PRONTO_GITHUB_ACCESS_TOKEN'] || defined? RSpec
  begin
    require 'octokit'
  rescue LoadError
    abort "ERROR: If you want to use the GitHub integration, you need to " +
          "add the 'octokit' gem to your Gemfile"
  end
  require 'pronto/github'
  require 'pronto/formatter/github_formatter'
  require 'pronto/formatter/github_status_formatter'
  require 'pronto/formatter/github_combined_status_formatter'
  require 'pronto/formatter/github_pull_request_formatter'
  require 'pronto/formatter/github_pull_request_review_formatter'
end
if ENV['PRONTO_GITLAB_API_PRIVATE_TOKEN'] || defined? RSpec
  begin
    require 'gitlab'
  rescue LoadError
    abort "ERROR: If you want to use the GitLab integration, you need to " +
          "add the 'gitlab' gem to your Gemfile"
  end
  require 'httparty'
  require 'pronto/gitlab'
  require 'pronto/formatter/gitlab_formatter'
  require 'pronto/formatter/gitlab_merge_request_review_formatter'
end
if ENV['PRONTO_BITBUCKET_USERNAME'] || defined? RSpec
  begin
    require 'httparty'
  rescue LoadError
    abort "ERROR: If you want to use the BitBucket integration, you need to " +
          "add the 'httparty' gem to your Gemfile"
  end
  require 'pronto/clients/bitbucket_client'
  require 'pronto/clients/bitbucket_server_client'
  require 'pronto/bitbucket'
  require 'pronto/bitbucket_server'
  require 'pronto/formatter/bitbucket_formatter'
  require 'pronto/formatter/bitbucket_pull_request_formatter'
  require 'pronto/formatter/bitbucket_server_pull_request_formatter'
end

module Pronto
  def self.run(commit = 'master', repo_path = '.',
               formatters = [Formatter::TextFormatter.new], file = nil)
    commit ||= 'master'

    repo = Git::Repository.new(repo_path)
    options = { paths: [file] } if file
    patches = repo.diff(commit, options)

    result = Runners.new.run(patches)

    Array(formatters).each do |formatter|
      formatted = formatter.format(result, repo, patches)
      puts formatted if formatted
    end

    result
  end
end
