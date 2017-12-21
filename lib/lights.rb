require "hue"
require 'mqtt'

hue_client = Hue::Client.new
mqtt_client = MQTT::Client.connect(host: 'raspberrypi.local', port: 1883)

GROUP_NAME = 'Living room'
BRIGHTNESS = 140

def set_group_lights(group, set_to_value)
  state_on = false
  group.lights.each do |light| 
    set_light(light, set_to_value)
  end
  state_on
end

def set_light(light, set_to_value)
  state_on = false
  light.brightness = BRIGHTNESS
  if set_to_value == true
    light.on!
    state_on = true
  else
    state_on = false
    light.off!
  end
  state_on
end


group = hue_client.groups.find {|g| g.name === GROUP_NAME }
state_on = set_group_lights(group, false)

puts "Initial State: #{state_on}"
unless group
  throw "Group not found"
end

mqtt_client.subscribe('hermes/nlu/intentParsed')

mqtt_client.get do |topic,message|
  response = JSON.parse(message)
  intent = response["intent"]["intentName"]
  set_to_value = true
  case intent
  when 'josh:lightsTurnOnSet'
    set_to_value = true
  when 'josh:lightsTurnOff'
    set_to_value = false
  end

  puts "Intent #{intent}"
  puts "Set lights to: #{set_to_value}"

  if response["slots"].empty?
    puts 'handle all lights'
    hue_client.lights.each do |light|
      state_on = set_light(light, set_to_value)
    end
  else
    room = response["slots"][0]["rawValue"]
    puts "Handle room #{room}"
    group = hue_client.groups.find {|g| g.name.downcase == room.downcase }
    puts group.inspect
    unless group.nil?
      puts "Current State: #{state_on}"
      state_on = set_group_lights(group, set_to_value)
      puts "New State: #{state_on}"
    end
  end
end


# {
#   "input": "bedroom lights on",
#   "intent": {
#     "intentName": "josh:lightsTurnOnSet",
#     "probability": 0.8170398
#   },
#   "slots": [
#     {
#       "rawValue": "bedroom",
#       "value": {
#         "kind": "Custom",
#         "value": "bedroom"
#       },
#       "range": {
#         "start": 0,
#         "end": 7
#       },
#       "entity": "house_room",
#       "slotName": "house_room"
#     }
#   ]
# }