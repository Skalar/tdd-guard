require 'non_existent_module'

RSpec.describe 'Calculator' do
  it 'should add numbers correctly' do
    expect(2 + 3).to eq(5)
  end
end
