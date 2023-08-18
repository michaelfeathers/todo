$:.unshift File.dirname(__FILE__)

require 'day'


describe Day do

  it 'constructs a day from a string' do
    day = Day.new("2022-12-21")
    expect(day.month).to eq("Dec")
  end


end
