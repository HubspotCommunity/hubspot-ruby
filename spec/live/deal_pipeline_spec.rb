describe 'Deals pipeline API Live test', live: true do

  before do
    Hubspot.configure hapikey: 'demo'
  end

  let(:params) do
    {
      'label' => 'auto pipeline1',
      'stages' => [
        {
          'label' => 'initial state',
          'displayOrder' => 0,
          'probability' => 0.5
        },
        {
          'label' => 'next state',
          'displayOrder' => 1,
          'probability' => 0.9
        }
      ]
    }
  end

  it 'should create, find, update and destroy' do
    pipeline = Hubspot::DealPipeline.create!(params)

    expect(pipeline.label).to eql 'auto pipeline1'
    expect(pipeline.stages.size).to eql 2
    expect(pipeline.stages.first['label']).to eql 'initial state'
    expect(pipeline.stages[1]['label']).to eql 'next state'

    pipeline.destroy!
  end
end
