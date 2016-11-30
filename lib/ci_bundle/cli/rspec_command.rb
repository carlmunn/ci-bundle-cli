module CiBundle::Cli
  class RspecCommand < BaseCommand
    def run

      files = @opts[:file].join(' ')

      dep_file = "deprecations.log"

      cmds = [].tap do |ary|
        ary.concat(["cd #{_path}"]) if _path
        ary.concat([*pre_run_commands])
        ary.concat(["bundle exec rspec #{files} --deprecation-out #{dep_file} --format j"])
      end

      _log("PRE CMDS: #{cmds.join(", ")}")

      # Get the last line, JSON is place on one night
      # and we can avoid all the other stdout.
      stdout_result = run_command(cmds.join(';'))

      begin  

        _log("RESULT: #{stdout_result.inspect}")

        #write_to_file(result, postfix: 'before-before')

        json_result = get_json(stdout_result)

        # Get the last line
        write_to_file(json_result)

        # Convert JSON to a ruby hash
        hash_result = parse(json_result, input_type: :json)

        check_for_failure(hash_result)

      rescue => exp
        # Write JSON to FS for analyse
        #write_to_file(stdout_result)
        raise exp
      end

      hash_result
    end

    private
    def check_for_failure(result)
      if has_failure?(result)
        notify(failure_email_hash(result), by: :email)
      else
        notify(success_email_hash, by: :email)
      end
    end

    # RSpec, when using --format j it won't return JSON as the last line if an
    # exception occurs.
    def get_json(result)
      #result.split("\n").select {|str| str.match(/^{version/) }.first
      result.split("\n").last
    end

    def failure_email_hash(body_hash)

      _from_email = @opts[:email].first
      _to_email   = @opts[:email]
      
      {
        to:        _to_email,
        from:      "#{_from_email} <Tests>",
        subject:   email_subject("🔥 Test Results: #{body_hash['summary_line']}"),
        body_hash: body_hash
      }
    end

    def success_email_hash
      {
        to:        @opts[:email],
        from:      "#{@opts[:email].first} <Tests>",
        subject:   email_subject("✔ All tests passed")
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

    def write_to_file(result, postfix: 'results')
      timestamp = Time.now.strftime("%Y%m%d_%H-%M-%S")
      File.open("test-report-#{timestamp}.#{postfix}", 'w') {|file| file.write(result) }
    end
  end
end