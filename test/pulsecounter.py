import time
import RPi.GPIO as GPIO

# Prepare channel
BCM_CHANNEL = 24
GPIO.setmode(GPIO.BCM)
GPIO.setup(BCM_CHANNEL, GPIO.IN)

# Prepare callback
i = 0;
def my_callback(channel):
    global i
    i += 1;
    print(i)

# Start listening
GPIO.add_event_detect(BCM_CHANNEL, GPIO.RISING, callback=my_callback)  # add rising edge detection on a channel

# Idle in main thread
while True:
    time.sleep(1)

 # For completeness although we newer get here
GPIO.cleanup()