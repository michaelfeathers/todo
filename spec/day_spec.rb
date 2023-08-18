$:.unshift File.dirname(__FILE__)

require 'day'


describe Day do
  it 'constructs a day from a string' do
    day = Day.from_text("2022-12-21")
    expect(day.day).to    eq("21")
    expect(day.month).to  eq("Dec")
    expect(day.year).to   eq("2022")

    expect(day.month_no).to eq(12)
  end

end
