require "spec_helper"

describe CiBundle::Cli do

  let(:rspec_json) {
    {
      description: "Description about this test",
      passed: "success",
      examples: [],
      file_path: "/path-to/file.rb"
    }
  }

  before :each do
    allow(Open3).to receive(:capture3).and_return(rspec_json.to_json)
    @mail = double(:mail)
    allow(Mail).to receive(:new).and_return(@mail)
  end

  it "has a version number" do
    expect(CiBundle::Cli::VERSION).not_to be nil
  end

  it "tests basic rspec command" do
    expect(@mail).to receive(:deliver!)
    CiBundle::Cli.run('rspec', {path: './path/to/rspec', verbose: true, email: 'me@test.com'})
  end
end
