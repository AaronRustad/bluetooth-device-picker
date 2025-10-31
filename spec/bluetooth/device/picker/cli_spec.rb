# frozen_string_literal: true

RSpec.describe Bluetooth::Device::Picker::CLI do
  let(:blueutil_json) do
    <<~JSON
      [
        {"address":"04-4b-ed-ed-3a-c8","recentAccessDate":"2025-10-31T14:36:53-06:00","connected":true,"name":"Jack Black’s Trackpad"},
        {"address":"08-65-18-58-73-c8","recentAccessDate":"2025-10-31T14:36:53-06:00","connected":false,"name":"Jack’s AirPods Pro"},
        {"address":"c8-69-cd-51-98-59","recentAccessDate":"2025-10-31T14:36:53-06:00","connected":false,"name":"Basement TV"}
      ]
    JSON
  end
  let(:command_double) { instance_double(TTY::Command) }
  let(:command_result) { instance_double(TTY::Command::Result, out: blueutil_json) }
  let(:prompt_double) { instance_double(TTY::Prompt) }
  let(:pastel_double) { double("Pastel") }
  let(:cli) { described_class.new }

  before do
    allow(TTY::Command).to receive(:new).and_return(command_double)
    allow(command_double).to receive(:run).and_return(command_result)
    allow(TTY::Prompt).to receive(:new).and_return(prompt_double)
    allow(Pastel).to receive(:new).and_return(pastel_double)
    allow(pastel_double).to receive(:green).with("\u2713").and_return("✓")
  end

  describe "#run" do
    before do
      allow(cli).to receive(:ensure_blueutil_available)
    end

    it "builds interactive choices from parsed bluetooth devices" do
      captured_choices = nil

      allow(prompt_double).to receive(:select) do |_question, choices, **_opts|
        captured_choices = choices
        "Jack Black’s Trackpad ✓"
      end

      expect(cli).to receive(:toggle).with("04-4b-ed-ed-3a-c8", true)

      cli.run([])

      expect(captured_choices).to include("Jack Black’s Trackpad ✓", "Jack’s AirPods Pro")
      expect(captured_choices.first).to eq("Basement TV")
      expect(command_double).to have_received(:run).with("blueutil --paired --format json").once
    end

    it "memoizes bluetooth devices across interactive runs" do
      allow(prompt_double).to receive(:select).and_return("Basement TV")
      allow(cli).to receive(:toggle)

      cli.run([])
      cli.run([])

      expect(command_double).to have_received(:run).with("blueutil --paired --format json").once
    end
  end
end
