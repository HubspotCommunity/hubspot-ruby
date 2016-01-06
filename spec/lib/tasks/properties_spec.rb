require 'rake'
require 'stringio'

describe 'properties rake tasks', live: true do
  before :all do
    Rake.application.rake_require 'tasks/properties'
  end

  context 'Contact Properties' do
    let(:file) { '/tmp/contact-demo-props.json' }
    let(:hapikey) { 'demo' }

    describe 'properties:dump' do
      let :run_rake_task do
        Rake::Task['properties:dump'].reenable
        Rake.application.invoke_task "properties:dump[contact,#{file},#{hapikey}]"
      end

      it 'saves the properties to a file' do
        run_rake_task

        props = JSON.parse(File.read(file))
        expect(props.count).to be > 0
        expect(props['groups'].count).to be > 0
        expect(props['properties'].count).to be > 0
      end
    end

    describe 'properties:restore' do
      let :run_rake_task do
        Rake::Task['properties:restore'].reenable
        Rake.application.invoke_task "properties:restore[contact,#{file},#{hapikey}]"
      end

      it 'should not need to make any changes' do
        results = capture_stdout { run_rake_task }
        expect(results.include?('Created: ')).to be_false
        expect(results.include?('Updated: ')).to be_false
      end
    end

  end

  context 'Deal Properties' do
    let(:file) { '/tmp/deal-demo-props.json' }
    let(:hapikey) { 'demo' }

    describe 'properties:dump' do
      let :run_rake_task do
        Rake::Task['properties:dump'].reenable
        Rake.application.invoke_task "properties:dump[deal,#{file},#{hapikey}]"
      end

      it 'saves the properties to a file' do
        run_rake_task

        props = JSON.parse(File.read(file))
        expect(props.count).to be > 0
        expect(props['groups'].count).to be > 0
        expect(props['properties'].count).to be > 0
      end
    end

    describe 'properties:restore' do
      let :run_rake_task do
        Rake::Task['properties:restore'].reenable
        Rake.application.invoke_task "properties:restore[deal,#{file},#{hapikey}]"
      end

      it 'should not need to make any changes' do
        results = capture_stdout { run_rake_task }
        expect(results.include?('Created: ')).to be_false
        expect(results.include?('Updated: ')).to be_false
      end
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