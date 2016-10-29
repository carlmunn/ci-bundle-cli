module CiBundle::Cli
  class RunCommand < BaseCommand
    def run
      cmds = [*pre_run_commands].tap do |ary|
        ary << "cd #{_pwd}"
        ary << "./#{_basename}"
      end.join(';')

      result = run_command(cmds)
      result = parse(result)
      notify(result)
    end
  end
end