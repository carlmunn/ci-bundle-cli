require "spec_helper"

describe CiBundle::Cli do

  let(:debug) { false }

  let(:_opts) {{
    email:   [],
    file:    [],
    verbose: debug
  }}

  let(:rspec_json) {{
    description: "Description about this test",
    passed:      "success",
    examples:    [],
    file_path:   "/path-to/file.rb"
  }}

  before :each do
    Mail::TestMailer.deliveries.clear
  end

  def check_email(to_count: 1, subject: 'All tests passed')
    _deliveries = Mail::TestMailer.deliveries
    expect(_deliveries.size).to eql 1
    expect(_deliveries.first.to.size).to eql to_count
    expect(_deliveries.first.subject).to eql subject
  end

  context 'disabled commands' do
    
    before do
      allow(Open3).to receive(:capture3).and_return(rspec_json.to_json)
    end

    it "has a version number" do
      expect(CiBundle::Cli::VERSION).not_to be nil
    end

    it "tests basic rspec command" do
      options = _opts.merge!({path: './path/to/rspec', email: ['me@test.com']})
      CiBundle::Cli.run('rspec', options)
      check_email
    end

    it "tests two emails with basic rspec command" do
      options = _opts.merge!({path: './path/to/rspec', email: ['me@test.com', 'second@email.com']})
      CiBundle::Cli.run('rspec', options)
      check_email(to_count: 2)
    end
  end

  context 'rspec files' do

    let(:_test_dir) {File.join(File.dirname(__FILE__), '../..')}

    def rspec_file(name)
      File.join(File.absolute_path(_test_dir), "spec/resources/#{name}.rb")
    end

    it 'tests success rspec by using these tests (recursive)' do

      options = _opts.merge!({
        path:  _test_dir,
        file:  [rspec_file('success')],
        email: ['me@test.com', 'second@email.com']
      })

      CiBundle::Cli.run('rspec', options)

      check_email(to_count: 2)
    end

    it 'tests failure spec' do
      options = _opts.merge!({
        path:  _test_dir,
        file:  [rspec_file('failure')],
        email: ['me@test.com', 'second@email.com']
      })

      CiBundle::Cli.run('rspec', options)

      check_email(to_count: 2, subject: 'Test Results: 1 example, 1 failure')
    end

    it 'test mixed spec' do
      options = _opts.merge!({
        path:  _test_dir,
        file:  [rspec_file('mix')],
        email: ['me@test.com', 'second@email.com']
      })

      CiBundle::Cli.run('rspec', options)

      check_email(to_count: 2, subject: 'Test Results: 3 examples, 2 failures')
    end
  end
end