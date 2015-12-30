require 'rake'
require 'stringio'

describe 'contact_properties rake tasks', live: true do
  before :all do
    Rake.application.rake_require 'tasks/contact_properties'
  end

  let(:file){ '/tmp/demo-props.json'}
  let(:hapikey){ 'demo' }

  describe 'contact_properties:dump' do
    let :run_rake_task do
      Rake::Task['contact_properties:dump'].reenable
      Rake.application.invoke_task "contact_properties:dump[#{file},#{hapikey}]"
    end

    it 'saves the properties to a file' do
      run_rake_task

      props = JSON.parse(File.read(file))
      expect(props.count).to be > 0
      expect(props['groups'].count).to be > 0
      expect(props['properties'].count).to be > 0
    end
  end

  describe 'contact_properties:restore' do
    let :run_rake_task do
      Rake::Task['contact_properties:restore'].reenable
      Rake.application.invoke_task "contact_properties:restore[#{file},#{hapikey},true]"
    end

    it 'should not need to make any changes' do
      results = capture_stdout { run_rake_task }
      expect(results.include?('Creating new groups

Creating new properties

Updating existing properties')).to be_true
      expect(results.include?('Created: ')).to be_false
      expect(results.include?('Updated: ')).to be_false
    end
  end

  def capture_stdout
    previous, $stdout = $stdout, StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = previous
  end

end