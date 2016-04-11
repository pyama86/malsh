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
          [1, "memory.used" => nil],
          [2, "memory.used" => double(value: 1)],
        ])
        allow(Mackerel).to receive(:hosts).and_return([
          double(id: 1, name: "retire_host", displayName: nil),
          double(id: 2, name: "enable_host", displayName: nil),
        ])
        allow(Mackerel).to receive(:host).with(1).and_return(
          double(id: 1, name: "retire_host", displayName: nil),
        )
        allow(Mackerel).to receive(:host).with(2).and_return(
          double(id: 1, name: "retire_host", displayName: nil),
        )
      end
      subject { Malsh::CLI.new.invoke(:retire, [], {}) }

      it {
        is_expected.to be_truthy
        expect(Malsh::Notification::Base).to have_received(:notify).with("退役未了ホスト一覧", ["retire_host"])
      }
    end


    describe '.#maverick' do
      before do
        allow(Mackerel).to receive(:hosts).and_return([
          double(id: 1, name: "have_role_host", displayName: nil, roles: {test: 1}),
          double(id: 2, name: "maverick_host", displayName: nil, roles: {})
        ])
      end
      subject { Malsh::CLI.new.invoke(:maverick, [], {}) }

      it {
        is_expected.to be_truthy
        expect(Malsh::Notification::Base).to have_received(:notify).with("ロール無所属ホスト一覧", ["maverick_host"])
      }
    end

    describe '.#search' do
      before do
        allow(Mackerel).to receive(:hosts).and_return([
          {
            "id" => 1,
            "name" => "example_host",
            "meta" => {
              "cpu" => [0, 1]
            }
          }
        ])
      end

      shared_examples_for 'resource_check' do
        subject { Malsh::CLI.new.invoke(:search, [], options) }

        context 'unmatch' do
          before do
            resources.each_with_index do |resource,index|
              allow(Malsh).to receive(:host_metrics).with(1,resource,any_args).and_return(
                double(
                  metrics: [
                    double(time: 1, value: index.to_f),
                    double(time: 2, value: (index+1).to_f)
                  ]
                )
              )
            end
          end

          it 'upper threshould' do
            is_expected.to be_truthy
            expect(Malsh::Notification::Base).to have_received(:notify).with("ホスト一覧", [])
          end
        end

        context 'match' do
          before do
            resources.each_with_index do |resource,index|
              allow(Malsh).to receive(:host_metrics).with(1,resource,any_args).and_return(
                double(
                  metrics: [
                    double(time: 1, value: index.to_f)
                  ]
                )
              )
            end
          end

          it 'lower threshold' do
            is_expected.to be_truthy
            expect(Malsh::Notification::Base).to have_received(:notify).with("ホスト一覧", ["example_host"])
          end
        end
      end

      context 'cpu' do
        let(:options) { { cpu_threshold: 3 } }
        let(:resources) { %w(cpu.user.percentage cpu.iowait.percentage cpu.system.percentage) }
        it_behaves_like 'resource_check'
      end

      context 'memory' do
        let(:options) { { memory_threshold: 51 } }
        let(:resources) { %w(memory.used memory.cached memory.total) }
        it_behaves_like 'resource_check'
      end

      context 'cpu and memory' do
        let(:options) { { cpu_threshold: 3, memory_threshold: 141 } }
        let(:resources) { %w(cpu.user.percentage cpu.iowait.percentage cpu.system.percentage memory.used memory.cached memory.total) }
        it_behaves_like 'resource_check'
      end
    end
  end

  context 'options' do
    before do
      allow(Mackerel).to receive(:hosts).and_return([
        double(id: 1, name: "develop_host", displayName: nil, :[] => "develop_host"),
        double(id: 2, name: "host_local", displayName: nil, :[] => "host_local"),
        double(id: 3, name: "local_host", displayName: nil, :[] => "loal_host"),
        double(id: 4, name: "production_host", displayName: nil, :[] => "production_host")
      ])
    end

    describe 'subject' do
      subject { Malsh::CLI.new.invoke(:search, [], {regexp: ["dev"], subject: "subject"}) }

      it {
        is_expected.to be_truthy
        expect(Malsh::Notification::Base).to have_received(:notify).with("subject", ["develop_host"])
      }
    end

    describe 'regexp' do
      subject { Malsh::CLI.new.invoke(:search, [], {regexp: ["dev", "local$"]}) }

      it {
        is_expected.to be_truthy
        expect(Malsh::Notification::Base).to have_received(:notify).with("ホスト一覧", ["develop_host", "host_local"])
      }
    end

    describe 'invert_match' do
      subject { Malsh::CLI.new.invoke(:search, [], {regexp: ["dev", "local$"], invert_match: ["host_local"]}) }

      it {
        is_expected.to be_truthy
        expect(Malsh::Notification::Base).to have_received(:notify).with("ホスト一覧", ["develop_host"])
      }
    end
  end
end

