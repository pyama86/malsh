require 'spec_helper'
require 'ostruct'
describe Malsh::CLI do
  before do
    allow(Malsh::Notification::Base).to receive(:notify_host)
    Malsh.instance_variable_set(:@_hosts, nil)
  end

  context 'basic' do
    describe '.#search' do
      before do
        allow(Mackerel).to receive(:hosts).and_return([
          {
            "id" => 1,
            "name" => "example_host",
            "meta" => {
              "cpu" => [0, 1]
            },
            "roles" => {
              "service" => [
                "role"
              ]
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
            expect(Malsh::Notification::Base).to have_received(:notify_host).with("ホスト一覧", [])
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
            expect(Malsh::Notification::Base).to have_received(:notify_host).with("ホスト一覧", [
              {
                "id"=>1,
                "name"=>"example_host",
                "meta"=>{"cpu"=>[0, 1]},
                "roles" => {
                  "service" => ["role"]
                }
              }
            ])
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
end

