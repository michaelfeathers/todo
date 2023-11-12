$:.unshift File.dirname(__FILE__)

require 'day'
require 'fakeappio'



describe Day do
  it 'constructs a day from a string' do
    day = Day.from_text("2022-12-21")
    expect(day.day).to    eq("21")
    expect(day.month).to  eq("Dec")
    expect(day.year).to   eq("2022")

    expect(day.month_no).to eq(12)
  end

  it 'creates a text reprsentation of itself' do
    day = Day.from_text("2022-12-21")
    expect(day.to_s).to eq("2022-12-21")
  end

  it 'creates the next day'  do
    day = Day.from_text("2022-12-21").with_more_days(1)
    expect(day.to_s).to eq("2022-12-22")
  end

end
