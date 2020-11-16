module Pronto
  module Formatter
    def self.get(names)
      names ||= 'text'
      Array(names).map { |name| formatters[name.to_s] || TextFormatter }
        .uniq.map(&:new)
    end

    def self.names
      formatters.keys
    end

    def self.formatters
      formatters = {
        'json' => JsonFormatter,
        'checkstyle' => CheckstyleFormatter,
        'text' => TextFormatter,
        'null' => NullFormatter
      }

      if Pronto.const_defined?(:Github)
        formatters.merge!('github' => GithubFormatter,
                          'github_status' => GithubStatusFormatter,
                          'github_combined_status' => GithubCombinedStatusFormatter,
                          'github_pr' => GithubPullRequestFormatter,
                          'github_pr_review' => GithubPullRequestReviewFormatter)
      end
      if Pronto.const_defined?(:Gitlab)
        formatters.merge!('gitlab' => GitlabFormatter,
                          'gitlab_mr' => GitlabMergeRequestReviewFormatter)
      end
      if Pronto.const_defined?(:Bitbucket)
        formatters.merge!('bitbucket' => BitbucketFormatter,
                          'bitbucket_pr' => BitbucketPullRequestFormatter,
                          'bitbucket_server_pr' => BitbucketServerPullRequestFormatter)
      end

      formatters
    end
  end
end
