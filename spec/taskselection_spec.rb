$:.unshift File.dirname(__FILE__)

require 'spec_helper'
require 'taskselection'

describe TaskSelection do
  describe '#percent_of' do
    let(:descs) do
      [
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 1)), 'L'),
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 2)), 'R'),
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 3)), 'L'),
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 4)), 'W'),
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 5)), 'R')
      ]
    end

    let(:task_selection) { TaskSelection.new(descs) }

    it 'calculates the percentage of tasks in the selection compared to another selection' do
      other_descs = [
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 1)), 'L'),
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 2)), 'R'),
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 3)), 'L'),
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 4)), 'W'),
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 5)), 'R'),
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 6)), 'W'),
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 7)), 'L'),
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 8)), 'R'),
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 9)), 'W'),
        TaskDesc.new(Day.new(DateTime.new(2023, 1, 10)), 'L')
      ]
      other_selection = TaskSelection.new(other_descs)

      expect(task_selection.percent_of(other_selection)).to eq(50)
    end

    it 'returns 0 if the other selection is empty' do
      other_selection = TaskSelection.new([])

      expect(task_selection.percent_of(other_selection)).to eq(0)
    end

    it 'returns 100 if the other selection is the same as the current selection' do
      expect(task_selection.percent_of(task_selection)).to eq(100)
    end

    it 'returns 0 if the current selection is empty' do
      empty_selection = TaskSelection.new([])
      other_selection = TaskSelection.new(descs)

      expect(empty_selection.percent_of(other_selection)).to eq(0)
    end
  end
end
