require "spec_helper"
require 'byebug'

describe CiBundle::Cli do
  let(:debug) { false }

  let(:_opts) {{
    email:   [],
    file:    [],
    verbose: debug
  }}

  def json_example(attrs = {})
    {
      id:              './path/to_file_spec.rb[1:1:1:3:1:1]',
      description:     'Description about this test',
      status:          'passed',
      file_path:       './path/to_file_spec.rb',
      run_time:        0.100,
      pending_message: nil
    }.merge(attrs)
  end

  def json_result(examples = [])
    {
      'examples': examples,
      'seed': 1234,
      'summary': {
        "duration": 1,
        "example_count": 5,
        "failure_count": 0,
        "pending_count": 0,
        "errors_outside_of_examples_count": 0
      },
      'summary_line': '1 examples, 0 failures',
      'version': '3.9.2'
    }
  end

  before :each do
    Mail::TestMailer.deliveries.clear
  end

  def check_email(to_count: 1, subject: 'All tests passed')
    _deliveries = Mail::TestMailer.deliveries
    expect(_deliveries.size).to eql 1
    expect(_deliveries.first.to.size).to eql to_count
    expect(_deliveries.first.subject).to match /#{subject}/
  end

  context 'disabled commands' do
    it "has a version number" do
      expect(CiBundle::Cli::VERSION).not_to be nil
    end

    it "tests basic RSpec command with successful examples" do
      allow(Open3).to receive(:capture3).and_return(json_result([json_example]).to_json)
      options = _opts.merge!({path: './path/to/rspec', email: ['me@test.com']})
      CiBundle::Cli.run('rspec', options)
      check_email
    end

    it "tests basic RSpec command with failed example" do
      result = json_result([json_example(status: 'failed')])
      allow(Open3).to receive(:capture3).and_return(json_result([json_example]).to_json)
      options = _opts.merge!({path: './path/to/rspec', email: ['me@test.com']})
      CiBundle::Cli.run('rspec', options)
      check_email
    end

    it "tests two emails with basic RSpec command" do
      allow(Open3).to receive(:capture3).and_return(json_result([json_example]).to_json)
      options = _opts.merge!({path: './path/to/rspec', email: ['me@test.com', 'second@email.com']})
      CiBundle::Cli.run('rspec', options)
      check_email(to_count: 2)
    end
  end

  context 'rspec files' do
    let(:_test_dir) {File.join(File.dirname(__FILE__), '../..')}

    def rspec_file(name)
      File.join(File.absolute_path(_test_dir), "spec/resources/#{name}_test.rb")
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

    it 'generates CSV file' do
      expect(CiBundle::Cli::RspecCommand).to receive(:append_to_file)

      options = _opts.merge!({
        path:  _test_dir,
        file:  [rspec_file('mix')],
        email: ['me@test.com'],
        csv:   '/home/carl/tmp/csv-file.csv'
      })

      CiBundle::Cli.run('rspec', options)
    end

    it 'test synxtax error spec' do

      skip "Currently isn't away to avoid problems within tests itself"

      options = _opts.merge!({
        path:  _test_dir,
        file:  [rspec_file('mix'), rspec_file('syntax_error')],
        email: ['me@test.com'],
        verbose: true
      })

      CiBundle::Cli.run('rspec', options)

      check_email(to_count: 1, subject: 'Test Results: 3 examples, 3 failures')
    end
  end
end