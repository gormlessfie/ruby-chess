# frozen_string_literal: true

require './lib/board'

describe Board do

  context '#color_board' do
    context 'Even numbered rows, odd is black' do
      subject(:board) { described_class.new }

      it 'row zero space zero is white' do
        row_zero_space_zero = board.instance_variable_get(:@board)[0][0]
        expect(row_zero_space_zero.instance_variable_get(:@color)).to eq('white')
      end

      it 'row two space one is black' do
        row_three_space_one = board.instance_variable_get(:@board)[2][1]
        expect(row_three_space_one.instance_variable_get(:@color)).to eq('black')
      end

      it 'row six space seven is black' do
        row_six_space_seven = board.instance_variable_get(:@board)[6][7]
        expect(row_six_space_seven.instance_variable_get(:@color)).to eq('black')
      end
    end

    context 'Odd numbered rows, even is black' do
      subject(:board) { described_class.new }

      it 'row one space zero is black' do
        row_one_space_zero = board.instance_variable_get(:@board)[1][0]
        expect(row_one_space_zero.instance_variable_get(:@color)).to eq('black')
      end

      it 'row three space five is black' do
        row_three_space_five = board.instance_variable_get(:@board)[3][5]
        expect(row_three_space_five.instance_variable_get(:@color)).not_to eq('black')
      end

      it 'row four space 2 is black' do
        row_four_space_two = board.instance_variable_get(:@board)[4][2]
        expect(row_four_space_two.instance_variable_get(:@color)).to eq('white')
      end
    end
  end
end
