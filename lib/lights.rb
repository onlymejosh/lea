require "hue"
require 'mqtt'

hue_client = Hue::Client.new
mqtt_client = MQTT::Client.connect(host: '127.0.0.1', port: 1883)

GROUP_NAME = 'Living room'
BRIGHTNESS = 140

def set_group_lights(group, set_to_value)
  state_on = false
  group.lights.each do |light| 
    light.brightness = BRIGHTNESS
    if set_to_value == true
      light.on!
      state_on = true
    else
      state_on = false
      light.off!
    end
  end
  state_on
end


group = hue_client.groups.find {|g| g.name === GROUP_NAME }
state_on = set_group_lights(group, false)

puts "Initial State: #{state_on}"
# unless group
#   throw "Group not found"
# end

mqtt_client.subscribe('lea/hotword/detected')

mqtt_client.get do |topic,message|
  response = JSON.parse(message)
  group = hue_client.groups.find {|g| g.name === response["siteId"] }  
  puts "Current State: #{state_on}"
  state_on = set_group_lights(group, !state_on)
  puts "New State: #{state_on}"
end
