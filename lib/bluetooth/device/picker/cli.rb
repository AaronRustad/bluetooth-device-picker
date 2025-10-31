# frozen_string_literal: true

require "json"
require "tty-command"
require "tty-prompt"
require "pastel"

module Bluetooth
  module Device
    module Picker
      # CLI presents interactive commands for managing Bluetooth devices.
      class CLI
        def initialize
          @cmd = TTY::Command.new(printer: :null)
          @prompt = TTY::Prompt.new
          @pastel = Pastel.new
        end

        def run(args)
          ensure_blueutil_available

          command = args[0]
          mac_address = args[1]

          # Interactive mode when no arguments provided
          if command.nil?
            interactive_mode
            return
          end

          case command
          when "connect"
            connect(mac_address)
          when "disconnect"
            disconnect(mac_address)
          else
            puts "Usage: bluetooth-sound-picker [connect|disconnect] MAC_ADDRESS"
            exit 1
          end
        end

        private

        def interactive_mode
          if bluetooth_devices.empty?
            puts "No paired bluetooth devices found."
            exit 0
          end

          choices = build_choices(bluetooth_devices)

          # Ask user to select device
          selected_display_name = @prompt.select("Toggle device:", choices.keys, filter: true)
          mac_address = choices[selected_display_name]

          # Toggle the connection based on current state
          toggle(mac_address, bluetooth_devices[mac_address][:connected])
        rescue ::TTY::Reader::InputInterrupt, Interrupt
          exit 0
        end

        def bluetooth_devices
          @bluetooth_devices ||= begin
            result = @cmd.run("blueutil --paired --format json")
            raw_devices = ::JSON.parse(result.out)

            raw_devices.each_with_object({}) do |device, devices|
              mac_address = device["address"]
              next if mac_address.nil? || mac_address.empty?

              devices[mac_address] = {
                connected: device["connected"],
                name: device["name"] || mac_address
              }
            end
          rescue JSON::ParserError => e
            puts "Error parsing bluetooth device list: #{e.message}"
            exit 1
          end
        end

        def build_choices(devices)
          sorted_devices = devices.sort_by { |_mac, info| info[:name] }

          sorted_devices.each_with_object({}) do |(mac, info), choices|
            display_name =
              if info[:connected]
                "#{info[:name]} #{@pastel.green("\u2713")}"
              else
                info[:name]
              end
            choices[display_name] = mac
          end
        end

        def toggle(mac_address, is_connected)
          if is_connected
            disconnect(mac_address)
          else
            connect(mac_address)
          end
        end

        def connect(mac_address)
          if mac_address.nil? || mac_address.empty?
            puts "Error: MAC address is required"
            puts "Usage: bluetooth-sound-picker connect MAC_ADDRESS"
            exit 1
          end

          puts "Connecting to #{mac_address}..."
          @cmd.run("blueutil --connect #{mac_address}")
          puts "Successfully connected to #{mac_address}"
        rescue TTY::Command::ExitError => e
          puts "Error connecting to #{mac_address}: #{e.message}"
          exit 1
        end

        def disconnect(mac_address)
          if mac_address.nil? || mac_address.empty?
            puts "Error: MAC address is required"
            puts "Usage: bluetooth-sound-picker disconnect MAC_ADDRESS"
            exit 1
          end

          puts "Disconnecting from #{mac_address}..."
          @cmd.run("blueutil --disconnect #{mac_address}")
          puts "Successfully disconnected from #{mac_address}"
        rescue TTY::Command::ExitError => e
          puts "Error disconnecting from #{mac_address}: #{e.message}"
          exit 1
        end

        def ensure_blueutil_available
          return if system("command -v blueutil >/dev/null 2>&1")

          puts "Error: blueutil command not found. Please install blueutil and ensure it is available in your PATH."
          exit 1
        end
      end
    end
  end
end
