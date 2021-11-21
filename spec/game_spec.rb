# frozen_string_literal: true

require './lib/game'

describe Game do
  context '#send_update_king_check_condition' do
    subject(:game) { described_class.new }
    context 'Sends a message to king object to change @check to true or false' do
      let(:king) { double('king', check: false) }

      before do
        allow(:king).to receive(:send_update_king_check_condition)
      end

      it 'king receives the method send_update_king_check_condition' do
        expect { game.send_update_king_check_condition('white', true).to }
      end
    end
  end
end
