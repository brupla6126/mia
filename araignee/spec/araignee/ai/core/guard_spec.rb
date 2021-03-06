require 'araignee/ai/core/guard'
require 'araignee/ai/core/interrogator'
require 'spec_helpers/ai_helpers'

RSpec.describe Araignee::Ai::Core::Guard do
  include Araignee::Ai::Helpers

  let(:interrogator_busy) { Araignee::Ai::Helpers::InterrogatorBusy.new }
  let(:interrogator_failed) { Araignee::Ai::Helpers::InterrogatorFailed.new }
  let(:interrogator_succeeded) { Araignee::Ai::Helpers::InterrogatorSucceeded.new }
  let(:child_interrogator) { nil }
  let(:interrogator) { Araignee::Ai::Core::Interrogator.new(child: child_interrogator) }
  let(:guarded) { Araignee::Ai::Helpers::NodeSucceeded.new }

  let(:guard) { described_class.new(interrogator: interrogator, child: guarded) }

  before do
    interrogator_busy.state = initial_state
    interrogator_failed.state = initial_state
    interrogator_succeeded.state = initial_state
    interrogator.state = initial_state
    guarded.state = initial_state
    guard.state = initial_state
  end

  subject { guard }

  describe '#initialize' do
    it 'sets interrogator node' do
      expect(subject.interrogator).to eq(interrogator)
    end

    it 'sets guarded node' do
      expect(subject.child).to eq(guarded)
    end
  end

  describe '#process' do
    let(:request) { OpenStruct.new }

    subject { super().process(request) }

    context 'when interrogator returns :succeeded' do
      let(:child_interrogator) { interrogator_succeeded }

      it 'has called child#process' do
        expect(subject.succeeded?).to eq(true)
      end
    end

    context 'when interrogator returns :failed' do
      let(:child_interrogator) { interrogator_failed }

      it 'has failed' do
        expect(subject.failed?).to eq(true)
      end
    end

    context 'when interrogator returns :busy' do
      let(:child_interrogator) { interrogator_busy }

      it 'has failed' do
        expect(subject.failed?).to eq(true)
      end
    end
  end
end
