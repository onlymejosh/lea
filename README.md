# Lea

Lea is the voice of the house. 

## Hardware
 - Raspberry Pi
 - USB Microphone
 - Hue Bridge
 - Hue Lights

## Software
 - snips.ai For intent ASR
 - https://snowboy.kitt.ai/ - Custom hotword ala Lea

## Installation

1. Install mosquitto for the queuing system `brew install mosquitto`
2. Get snowboy running



Lea all lights off




python ./lea.py

## Things to know
LeaSpeaker - Small device which triggers hotword along with the room
LeaServer - Subscribes to `lea/hotword/detected` and then triggers:

`hermes/hotword/default/detected`
`{"siteId": "bedroom"}`

`hermes/dialogueManager/startSession`
`{"init":{"type":"action","text":null,"canBeEnqueued":false,"intentFilter":null},"customData":"bedroom"}`


## Flow
LeaSpeaker
1. lea.py waits for hotword (lea)
2. [LeaSpeaker] Triggers `lea/hotword/detected`
3. [LeaServer] Triggers `hermes/hotword/default/detected` and `hermes/dialogueManager/startSession`
4. [LeaServer] Waits for dialog with stuff