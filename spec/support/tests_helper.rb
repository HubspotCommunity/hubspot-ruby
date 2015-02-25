module TestsHelper
  def expect_count_and_offset(&block)  
    it 'returns only the number of objects specified by count' do
      result = block.call(count: 2)
      expect(result.size).to eql 2

      result = block.call(count: 4)
      expect(result.size).to eql 4
    end

    it 'returns objects by a specified offset' do
      non_offset_objects = block.call(count: 2)  	
      objects_with_offset = block.call(count: 2, offset: 2)
      expect(non_offset_objects).to_not eql objects_with_offset
    end
  end
end