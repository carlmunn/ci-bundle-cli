require "spec_helper"

describe CiBundle::Cli do
  it "has a version number" do
    expect(CiBundle::Cli::VERSION).not_to be nil
  end

  it "runs the check command" do
    CiBundle::Cli.run('check')
  end
end
