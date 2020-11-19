module Pronto
  module Formatter
    class GithubPullRequestCommentFormatter < PullRequestFormatter
      def client_module
        Github
      end

      def pretty_name
        'GitHub'
      end

      def submit_comments(client, comments)
        combined_text = comments.map(&:to_s).join("\n")
        combined_comment = Comment.new(nil, combined_text)
        client.create_issue_comment(combined_comment)
      rescue Octokit::UnprocessableEntity, HTTParty::Error => e
        $stderr.puts "Failed to post: #{e.message}"
      end

      def line_number(message, patches)
        line = patches.find_line(message.full_path, message.line.new_lineno)
        line.position
      end
    end
  end
end
