require 'araignee/ai/core/composite'

RSpec.describe Araignee::Ai::Core::Composite do
  let(:children) { (1..2).map { Araignee::Ai::Core::Node.new } }
  let(:filters) { [] }
  let(:picker) { nil }
  let(:sorter) { nil }

  let(:composite) { described_class.new(children: children, filters: filters, picker: picker, sorter: sorter) }

  subject { composite }

  describe '#initialize' do
    it 'response is :unknown' do
      expect(subject.response).to eq(:unknown)
    end

    it 'children are set' do
      expect(subject.children).to eq(children)
    end

    it 'children response are :unknown' do
      children.each { |child| expect(child.response).to eq(:unknown) }
    end

    it 'picker is nil' do
      expect(subject.picker).to eq(picker)
    end

    context 'with picker' do
      let(:picker) { Araignee::Ai::Core::Pickers::Picker.new }

      it 'picker is set' do
        expect(subject.picker).to eq(picker)
      end
    end

    context 'with sorter' do
      let(:sorter) { Araignee::Ai::Core::Sorters::Sorter.new }

      it 'sorter is set' do
        expect(subject.sorter).to eq(sorter)
      end
    end
  end

  describe '#child' do
    let(:child1) { Araignee::Ai::Core::Node.new }
    let(:child2) { Araignee::Ai::Core::Node.new }
    let(:child3) { Araignee::Ai::Core::Node.new(identifier: child1.identifier) }
    let(:children) { [child1, child2, child3] }

    let(:child_identifier) { child1.identifier }

    subject { composite.child(child_identifier) }

    it 'finds child' do
      expect(subject).to eq(child1)
    end

    context 'unknown child' do
      let(:child_identifier) { 'abcdef' }

      it 'does not find child' do
        expect(subject).to eq(nil)
      end
    end
  end

  describe '#add_child' do
    subject { super().add_child(added_child, index) }

    let(:added_child) { Araignee::Ai::Core::Node.new }
    let(:index) { :last }

    it 'should have all children' do
      expect(subject.children.count).to eq(3)
    end

    context 'invalid index' do
      context 'with wrong symbol' do
        let(:index) { :last_index }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError, "invalid index: #{index}")
        end
      end

      context 'with String' do
        let(:index) { '1' }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError, "invalid index: #{index}")
        end
      end

      context 'with nil' do
        let(:index) { nil }

        it 'inserts at last position' do
          expect(subject.children[subject.children.count - 1]).to eq(added_child)
        end
      end
    end

    context 'valid index' do
      it 'does not raise ArgumentError' do
        expect { subject }.not_to raise_error
      end

      context 'when insert at last position' do
        it 'inserts at last position' do
          expect(subject.children[subject.children.count - 1]).to eq(added_child)
          expect(subject.children.count).to eq(3)
        end
      end

      context 'when insert at specified position' do
        let(:index) { 1 }

        it 'inserts at specified position' do
          expect(subject.children[index]).to eq(added_child)
          expect(subject.children.count).to eq(3)
        end
      end
    end
  end

  describe '#remove_child' do
    subject { composite.remove_child(removed_child) }

    context 'known child' do
      let(:child) { Araignee::Ai::Core::Node.new }
      let(:children) { [child] }

      let(:removed_child) { child }

      it 'removes child' do
        expect(subject.children.include?(child)).to eq(false)
      end
    end

    context 'unknown child' do
      let(:child) { Araignee::Ai::Core::Node.new }
      let(:unknown) { Araignee::Ai::Core::Node.new }
      let(:children) { [child] }

      let(:removed_child) { unknown }

      it 'does not remove' do
        expect(subject.children.count).to eq(1)
      end
    end
  end

  describe 'reset_node' do
    subject { super().reset_node }

    after { subject }

    context 'returned value' do
      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end

    it 'reset response attribute' do
      expect(composite).to receive(:reset_attribute).with(:response)
    end

    context 'children' do
      let(:child) { double('[child]') }
      let(:children) { [child] }

      before { allow(child).to receive(:validate_attributes) }
      before { allow(child).to receive(:reset_node) }

      it 'calls reset_node on each child' do
        expect(child).to receive(:reset_node)
      end
    end

    context 'picker' do
      let(:picker) { double('[picker]') }

      before { allow(picker).to receive(:reset) }

      it 'calls picker#reset' do
        expect(picker).to receive(:reset)
      end
    end

    context 'sorter' do
      let(:sorter) { double('[sorter]') }

      before { allow(sorter).to receive(:reset) }

      it 'calls sorter#reset' do
        expect(sorter).to receive(:reset)
      end
    end
  end

  describe 'filter' do
    let(:node_running) { Araignee::Ai::Core::Node.new }
    let(:nodes) { [Araignee::Ai::Core::Node.new, node_running] }
    let(:filters) { [] }

    subject { super().send(:filter, nodes) }

    context 'without filters' do
      it 'returns passed nodes' do
        expect(subject).to eq(nodes)
      end
    end
  end

  describe 'pick_one' do
    let(:nodes) { [Araignee::Ai::Core::Node.new, Araignee::Ai::Core::Node.new] }

    subject { super().send(:pick_one, nodes) }

    context 'without picker' do
      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end

    context 'with picker' do
      let(:picker) { Araignee::Ai::Core::Pickers::Picker.new }

      before { allow(picker).to receive(:pick_one).with(nodes) { nodes[1] } }

      context '' do
        it 'calls picker#pick_one' do
          expect(picker).to receive(:pick_one).with(nodes)
          subject
        end
      end

      it 'returns nil' do
        expect(subject).to eq(nodes[1])
      end
    end
  end

  describe 'pick_many' do
    let(:nodes) { [Araignee::Ai::Core::Node.new, Araignee::Ai::Core::Node.new] }

    subject { super().send(:pick_many, nodes) }

    context 'without picker' do
      it 'returns passed nodes' do
        expect(subject).to eq(nodes)
      end
    end

    context 'with picker' do
      let(:picker) { Araignee::Ai::Core::Pickers::Picker.new }

      before { allow(picker).to receive(:pick_many).with(nodes) { nodes.first } }

      context '' do
        it 'calls picker#pick_many' do
          expect(picker).to receive(:pick_many).with(nodes)
          subject
        end
      end

      it 'returns nil' do
        expect(subject).to eq(nodes.first)
      end
    end
  end

  describe 'sort' do
    let(:nodes) { [Araignee::Ai::Core::Node.new, Araignee::Ai::Core::Node.new] }
    let(:sort_reverse) { false }

    subject { super().send(:sort, nodes, sort_reverse) }

    context 'without sorter' do
      it 'returns passed nodes' do
        expect(subject).to eq(nodes)
      end
    end

    context 'with sort' do
      let(:sorter) { Araignee::Ai::Core::Sorters::Sorter.new }

      before { allow(sorter).to receive(:sort).with(nodes, sort_reverse) { nodes } }

      context 'empty nodes passed' do
        let(:nodes) { [] }

        it 'does not call sorter#sort' do
          expect(sorter).not_to receive(:sort).with(nodes, sort_reverse)
          subject
        end
      end

      context 'valid nodes passed' do
        it 'does call sorter#sort' do
          expect(sorter).to receive(:sort).with(nodes, sort_reverse)
          subject
        end
      end

      it 'returns nodes sorted' do
        expect(subject).to match_array(nodes)
      end
    end
  end
end
