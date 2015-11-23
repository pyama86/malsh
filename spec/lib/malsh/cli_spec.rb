require 'spec_helper'
require 'ostruct'
describe Malsh::CLI do
  before do
    allow(Malsh::Notification::Base).to receive(:notify)
    Malsh.instance_variable_set(:@_hosts, nil)
  end

  context 'basic' do
    describe '.#retire' do
      before do
        allow(Malsh).to receive(:metrics).and_return([
            [1, double(loadavg5: double(value: 0))],
            [2, double(loadavg5: double(value: 1))],
        ])
        allow(Mackerel).to receive(:hosts).and_return([
          double(id: 1, name: "retire_host"),
          double(id: 2, name: "enable_host"),
        ])
      end
      subject { Malsh::CLI.new.invoke(:retire, [], {}) }

      it {
        is_expected.to be_truthy
        expect(Malsh::Notification::Base).to have_received(:notify).with("退役未了ホスト一覧", ["retire_host"])
      }
    end

    describe '.#find' do
      before do
        allow(Mackerel).to receive(:hosts).and_return([
          double(id: 1, name: "develop_host"),
          double(id: 2, name: "host_local"),
          double(id: 3, name: "local_host"),
          double(id: 4, name: "production_host"),
        ])
      end
      subject { Malsh::CLI.new.invoke(:find, [], {regexp: ["dev", "local$"]}) }

      it {
        is_expected.to be_truthy
        expect(Malsh::Notification::Base).to have_received(:notify).with("不要ホスト候補一覧", ["develop_host", "host_local"])
      }
    end

    describe '.#maverick' do
      before do
        allow(Mackerel).to receive(:hosts).and_return([
          double(id: 1, name: "have_role_host", roles: {test: 1}),
          double(id: 2, name: "maverick_host", roles: {})
        ])
      end
      subject { Malsh::CLI.new.invoke(:maverick, [], {}) }

      it {
        is_expected.to be_truthy
        expect(Malsh::Notification::Base).to have_received(:notify).with("ロール無所属ホスト一覧", ["maverick_host"])
      }
    end
  end
  context 'options' do
    describe 'subject' do
      before do
        allow(Mackerel).to receive(:hosts).and_return([
          double(id: 1, name: "develop_host")
        ])
      end
      subject { Malsh::CLI.new.invoke(:find, [], {regexp: ["dev"], subject: "subject"}) }

      it {
        is_expected.to be_truthy
        expect(Malsh::Notification::Base).to have_received(:notify).with("subject", ["develop_host"])
      }
    end

    describe 'invert_match' do
      before do
        allow(Mackerel).to receive(:hosts).and_return([
          double(id: 1, name: "develop_host"),
          double(id: 2, name: "host_local"),
          double(id: 3, name: "local_host"),
          double(id: 4, name: "production_host"),
        ])
      end
      subject { Malsh::CLI.new.invoke(:find, [], {regexp: ["dev", "local$"], invert_match: ["host_local"]}) }

      it {
        is_expected.to be_truthy
        expect(Malsh::Notification::Base).to have_received(:notify).with("不要ホスト候補一覧", ["develop_host"])
      }
    end
  end
end

