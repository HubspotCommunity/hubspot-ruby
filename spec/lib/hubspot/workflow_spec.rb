describe Hubspot::Workflow do

  before{ Hubspot.configure(hapikey: 'demo') }

  describe '#enroll_contact' do
    context 'success' do
      cassette 'enroll_contact_in_workflow_success'
      it "returns a 204 response for a success" do
        email = "testingapis@hubspot.com"
        workflow = Hubspot::Workflow.new({'name' => "hello workflow", 'id' => 2582322})
        expect {
          workflow.enroll_contact(email: email)
        }.not_to raise_error
      end
    end

    context 'workflow without any steps' do
      cassette 'enroll_contact_in_workflow_no_steps'
      it "returns a 412 if the workflow is not valid" do
        email = "testingapis@hubspot.com"
        workflow = Hubspot::Workflow.new({'name' => "hello workflow", 'id' => 2325759})
        expect {
          workflow.enroll_contact(email: email)
        }.to raise_error(/There are no steps on this workflow to execute/)
      end
    end

    context 'invalid email' do
      cassette 'enroll_contact_in_workflow_failed_email'
      it "returns a 404 if the customer email does not exist" do
        email = "hahha@hubspot.com"
        workflow = Hubspot::Workflow.new({'name' => "hello workflow", 'id' => 2582322})
        expect {
          workflow.enroll_contact(email: email)
        }.to raise_error(/Couldn't find a Contact with the email 'hahha@hubspot.com'/)
      end
    end

    context 'invalid workflow id' do
      cassette 'enroll_contact_in_workflow_failed_workflowId'
      it "returns a 404 if the workflow does not exist" do
        email = "testingapis@hubspot.com"
        workflow = Hubspot::Workflow.new({'name' => "hello workflow", 'id' => 22210900})
        expect {
          workflow.enroll_contact(email: email)
        }.to raise_error(/resource not found/)
      end
    end
  end

  describe '.all' do
    context 'all workflows' do
      cassette 'find_all_workflows'
      it 'must get the workflows list' do
        workflows = Hubspot::Workflow.all

        expect(workflows.size).to eql 25

        first = workflows.first
        last = workflows.last

        expect(first).to be_a Hubspot::Workflow
        expect(first.id).to eql 2325759
        expect(first.name).to eql 'New Workflow'

        expect(last).to be_a Hubspot::Workflow
        expect(last.id).to eql 2582322
        expect(last.name).to eql 'Test Workflow'
      end

      it "must get the workflows list for page 2" do
        workflows = Hubspot::Workflow.all({page: 2})

        expect(workflows.size).to eql 25

        first = workflows.first
        last = workflows.last

        expect(first).to be_a Hubspot::Workflow
        expect(first.id).to eql 2325759
        expect(first.name).to eql 'New Workflow'

        expect(last).to be_a Hubspot::Workflow
        expect(last.id).to eql 2582322
        expect(last.name).to eql 'Test Workflow'
      end
    end

  end
end
