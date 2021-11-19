# frozen_string_literal: true

require './lib/unit_collision'

describe UnitCollision do
  context '#provide_problem_spaces_same_color' do
    subject(:collision) { described_class.new }
    let(:rook_piece) { double('rook', color: 'white', possible_moves: [[[6, 0]], [[7, 1]]]) }

    it 'returns [[6, 0], [7, 1]]' do
      expect(collision(rook_piece)).to eq([[6, 0], [7, 1]])
    end
  end
end
