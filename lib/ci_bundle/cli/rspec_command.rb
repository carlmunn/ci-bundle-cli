module CiBundle::Cli
  class RspecCommand < BaseCommand
    def run

      files = @opts[:file].join(' ')

      cmds = [].tap do |ary|
        ary.concat(["cd #{_path}"]) if _path
        ary.concat([*pre_run_commands])
        ary.concat(["bundle exec rspec #{files} --format j"])
      end

      _log("COMMANDS: #{cmds.join(", ")}")

      # Get the last line, JSON is place on one night
      # and we can avoid all the other stdout.
      result = run_command(cmds.join(';'))

      _log("RESULT: #{result}")

      # Get the last line
      result = result.split("\n").last

      # Convert JSON to a ruby hash
      result = parse(result, input_type: :json)

      if has_failure?(result)
        notify(failure_email_hash(result), by: :email)
      else
        notify(success_email_hash, by: :email)
      end

      result
    end

    private
    def failure_email_hash(body_hash)

      _from_email = @opts[:email].first
      _to_email   = @opts[:email]
      
      {
        to:        _to_email,
        from:      _from_email,
        subject:   email_subject("Test Results: #{body_hash['summary_line']}"),
        body_hash: body_hash
      }
    end

    def success_email_hash
      {
        to:        @opts[:email],
        from:      @opts[:email].first,
        subject:   email_subject("All tests passed")
      }
    end

    def email_subject(subject)
      [].tap do |ary|
        ary << "[#{@opts[:namespace]}]" if @opts[:namespace]
        ary <<subject
      end.join(" ")
    end

    def has_failure?(result)
      result['examples'].any? {|example| example['status'] == 'failed' }
    end

    def _log(msg)
      CiBundle::Cli.log(msg)
    end
  end
end