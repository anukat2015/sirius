require 'spec_helper'
require 'sirius/period'
describe Sirius::Period do

  describe '#parse' do

    it 'parses time values' do
      period = Sirius::Period.parse('7:30', '9:00')
      expect(period.starts_at).to eq(Time.parse('7:30'))
      expect(period.ends_at).to eq(Time.parse('9:00'))
    end

    it 'parses date values' do
      period = Sirius::Period.parse('11. 12. 2010', '15. 4. 2011')
      expect(period.starts_at).to eq(Time.parse('11. 12. 2010'))
      expect(period.ends_at).to eq(Time.parse('15. 4. 2011'))
    end

  end

  describe '#==' do

    it 'compares positively with equal instance' do
      period_a = Sirius::Period.parse('11. 12. 2010', '15. 4. 2011')
      period_b = Sirius::Period.parse('11. 12. 2010', '15. 4. 2011')
      expect(period_a == period_b).to be_truthy
    end

    it 'compares negatively with nonequal instance' do
      period_a = Sirius::Period.parse('11. 12. 2010', '15. 4. 2011')
      period_b = Sirius::Period.parse('11. 12. 2010', '16. 4. 2011')
      expect(period_a == period_b).to be_falsey
    end
  end

end
