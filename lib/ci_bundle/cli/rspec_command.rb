module CiBundle::Cli
  class RspecCommand < BaseCommand
    def run

      cmds = [*pre_run_commands].tap do |ary|
        ary << "cd #{_path}"
        ary << "bundle exec rspec --format j"
      end.join(';')

      result = run_command(cmds)
      result = parse(result, input_type: :json)

      notify(email_hash(result), by: :email)
    end

    private
    def email_hash(json_data)

      body = json_data['examples'].map do |hsh|
        [hsh['description'], hsh['passed'], hsh['file_path']].join(' ')
      end.join("\n")

      {
        to: "carl.munn@open2view.com",
        from: 'carl.munn@open2view.com',
        subject: json_data['summary_line'],
        body: {name: 'World!'}
      }
    end
  end
end