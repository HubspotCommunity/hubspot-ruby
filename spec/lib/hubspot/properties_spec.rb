module Hubspot
  describe Properties do
    let(:params) { { 'name'                          => 'amount_of_new_money_lined_up',
                     'label'                         => 'New Money Lined Up (Over $50K or Under $50K)',
                     'description'                   => '',
                     'groupName'                     => 'onboarding_questionnaire',
                     'type'                          => 'enumeration',
                     'fieldType'                     => 'select',
                     'options'                       => [{ 'description' => '', 'value' => 'option0', 'readOnly' => false, 'label' => 'Under $50K', 'displayOrder' => 0, 'hidden' => false, 'doubleData' => 0.0 },
                                                         { 'description' => '', 'value' => 'option1', 'readOnly' => false, 'label' => '$50K and above', 'displayOrder' => 1, 'hidden' => false, 'doubleData' => 0.0 },
                                                         { 'description' => nil, 'value' => 'option2', 'readOnly' => nil, 'label' => 'Not applicable', 'displayOrder' => 2, 'hidden' => false, 'doubleData' => nil }],
                     'formField'                     => true,
                     'displayOrder'                  => 0,
                     'readOnlyDefinition'            => false,
                     'hidden'                        => false,
                     'mutableDefinitionNotDeletable' => false,
                     'displayMode'                   => 'current_value',
                     'deleted'                       => false,
                     'createdUserId'                 => 2334900,
                     'calculated'                    => false,
                     'readOnlyValue'                 => false,
                     'externalOptions'               => false,
                     'updatedUserId'                 => 2225340 } }
    let(:valid_params) { { 'name'         => 'amount_of_new_money_lined_up',
                           'groupName'    => 'onboarding_questionnaire',
                           'description'  => '',
                           'fieldType'    => 'select',
                           'formField'    => true,
                           'type'         => 'enumeration',
                           'displayOrder' => 0,
                           'label'        => 'New Money Lined Up (Over $50K or Under $50K)',
                           'options'      => [{ 'description' => '', 'value' => 'option0', 'label' => 'Under $50K', 'hidden' => false, 'displayOrder' => 0 },
                                              { 'description' => '', 'value' => 'option1', 'label' => '$50K and above', 'hidden' => false, 'displayOrder' => 1 },
                                              { 'description' => nil, 'value' => 'option2', 'label' => 'Not applicable', 'hidden' => false, 'displayOrder' => 2 }]
    } }

    context '.valid_params' do
      it 'should strip out extra keys and their values' do
        result = Hubspot::Properties.valid_params(params)
        expect(Properties.same?(result, valid_params))
      end
    end

  end
end
