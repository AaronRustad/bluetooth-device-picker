# frozen_string_literal: true

RSpec.describe Bluetooth::Device::Picker do
  it "has a version number" do
    expect(Bluetooth::Device::Picker::VERSION).not_to be nil
  end
end
