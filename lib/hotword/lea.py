import snowboydecoder
import sys
import signal
import paho.mqtt.client as mqtt

interrupted = False

MQTT_ADDRESS = 'raspberrypi.local'
MQTT_PORT = '1883'
mqtt_client = mqtt.Client()

siteId = "Living room"
def signal_handler(signal, frame):
    global interrupted
    interrupted = True


def interrupt_callback():
    global interrupted
    return interrupted

def publish_detect():
  mqtt_client.connect(MQTT_ADDRESS, int(MQTT_PORT))
  mqtt_client.publish('lea/hotword/detected', payload="{\"siteId\":\"" + siteId + "\"}", qos=0)
  # Instead of trigger per room using siteId we can trigger with customData
  # mqtt_client.publish('hermes/hotword/default/detected', payload="{\"siteId\":\"" + siteId + "\"}", qos=0)

  action = "{\"type\":\"action\",\"text\":null,\"canBeEnqueued\":false,\"intentFilter\":null}"
  jsonString = "{\"customData\":\"" + siteId + "\",\"init\":" + action + "}"
  mqtt_client.publish('hermes/dialogueManager/startSession', payload=jsonString, qos=0)

  return snowboydecoder.play_audio_file

if len(sys.argv) == 1:
    print("Error: need to specify model name")
    print("Usage: python demo.py your.model")
    sys.exit(-1)

model = sys.argv[1]

# capture SIGINT signal, e.g., Ctrl+C
signal.signal(signal.SIGINT, signal_handler)

detector = snowboydecoder.HotwordDetector(model, sensitivity=0.5)
print('Listening... Press Ctrl+C to exit')

# main loop
detector.start(detected_callback=publish_detect,
               interrupt_check=interrupt_callback,
               sleep_time=0.03)

detector.terminate()