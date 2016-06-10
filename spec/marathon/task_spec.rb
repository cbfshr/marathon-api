require 'spec_helper'

describe Marathon::Task do

  describe '#to_s' do
    subject { described_class.new({
        'id'      => 'task-id-foo',
        'appId'   => '/app/foo',
        'host'    => 'foo-host',
        'ports'   => [31000, 31001],
        'version' => 'foo-version'
      }, double(Marathon::MarathonInstance)) }

    let(:expected_string) do
      "Marathon::Task { :id => task-id-foo :appId => /app/foo :host => foo-host }"
    end

    let(:expected_pretty_string) do
      "Task ID:    task-id-foo\n" + \
      "App ID:     /app/foo\n" + \
      "Host:       foo-host\n" + \
      "Ports:      31000,31001\n" + \
      "Staged at:  \n" + \
      "Started at: \n" + \
      "Version:    foo-version"
    end

    its(:to_s) { should == expected_string }
    its(:to_pretty_s) { should == expected_pretty_string }
  end

  describe '#to_json' do
    subject { described_class.new({
        'id'    => 'task-id-foo',
        'appId' => '/app/foo',
        'host'  => 'foo-host',
      }, double(Marathon::MarathonInstance)) }

    let(:expected_string) do
      '{"id":"task-id-foo","appId":"/app/foo","host":"foo-host"}'
    end

    its(:to_json) { should == expected_string }
  end

  describe '#delete!' do
    let(:task) { described_class.new({
      'id' => 'task_123', 'appId' => '/app/foo'
    }, double(Marathon::MarathonInstance)) }

    it 'deletes the task' do
      expect(described_class).to receive(:delete).with('task_123', false)
      task.delete!
    end
  end

  describe '.list' do
    subject { described_class }

    it 'raises error when run with strange status' do
      expect {
        subject.list('foo')
      }.to raise_error(Marathon::Error::ArgumentError)
    end

    it 'lists tasks', :vcr do
      tasks = subject.list
      expect(tasks.size).to be_within(1).of(2)
      expect(tasks.first).to be_instance_of(described_class)
    end

    it 'lists running tasks', :vcr do
      tasks = subject.list('running')
      expect(tasks.size).to be_within(1).of(2)
      expect(tasks.first).to be_instance_of(described_class)
    end
  end

  describe '.get' do
    subject { described_class }

    it 'gets tasks of an app', :vcr do
      tasks = subject.get('/ubuntu2')
      expect(tasks.size).not_to eq(0)
      expect(tasks.first).to be_instance_of(described_class)
      expect(tasks.first.appId).to eq('/ubuntu2')
    end
  end

  describe '.delete' do
    subject { described_class }

    it 'kills a tasks of an app', :vcr do
      tasks = subject.get('/ubuntu2')
      subject.delete(tasks.first.id)
    end
  end

  describe '.delete_all' do
    subject { described_class }

    it 'kills all tasks of an app', :vcr do
      subject.delete_all('/ubuntu2')
    end
  end

end
