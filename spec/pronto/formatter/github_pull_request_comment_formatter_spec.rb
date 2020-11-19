module Pronto
  module Formatter
    describe GithubPullRequestCommentFormatter do
      let(:formatter) { described_class.new }

      let(:repo) { Git::Repository.new('spec/fixtures/test.git') }
      let(:messages) { [message, message] }
      let(:message) { Message.new(patch.new_file_full_path, line, :info, '') }
      let(:patch) { repo.show_commit('64dadfd').first }
      let(:line) { patch.added_lines.first }
      let(:patches) { repo.diff('64dadfd^') }

      describe '#format' do
        subject { formatter.format(messages, repo, patches) }

        before do
          ENV['PRONTO_PULL_REQUEST_ID'] = '10'

          Octokit::Client.any_instance
            .should_receive(:pull_comments)
            .once
            .and_return([])
        end

        specify do
          Octokit::Client.any_instance
            .should_receive(:add_comment)
            .once

          subject
        end

        context 'error handling' do
          let(:error_response) do
            {
              status: 422,
              body: {
                message: 'Validation Failed',
                errors: [
                  resource: 'Issue',
                  field: 'title',
                  code: 'missing_field'
                ]
              }.to_json,
              response_headers: {
                content_type: 'json'
              }
            }
          end

          it 'handles and prints details' do
            error = Octokit::UnprocessableEntity.from_response(error_response)
            Octokit::Client.any_instance
              .should_receive(:add_comment)
              .and_raise(error)

            $stderr.should_receive(:puts) do |line|
              line.should =~ /Failed to post/
              line.should =~ /Validation Failed/
              line.should =~ /missing_field/
              line.should =~ /Issue/
            end
            subject
          end
        end
      end

      describe '#submit_comments' do
        subject { formatter.submit_comments(client, comments) }
        let(:client) { Github.new(repo) }
        let(:comments) do
          [
            Comment.new(nil, 'Some text that is not a line comment'),
            Comment.new('3e0e3ab', 'body', '/path/to/file', 1)
          ]
        end

        before do
          ENV['PRONTO_PULL_REQUEST_ID'] = '10'
        end

        specify do
          expected_body = <<~BODY.chomp
            Some text that is not a line comment
            [3e0e3ab] /path/to/file:1 - body
          BODY

          Octokit::Client.any_instance
            .should_receive(:add_comment)
            .with(nil, ENV['PRONTO_PULL_REQUEST_ID'].to_i, expected_body)
            .once

          subject
        end
      end
    end
  end
end
