module Pronto
  Comment = Struct.new(:sha, :body, :path, :position) do
    def ==(other)
      position == other.position &&
        path == other.path &&
        body == other.body
    end

    def to_s
      if sha || path || position
        "[#{sha}] #{path}:#{position} - #{body}"
      else
        body
      end
    end
  end
end
