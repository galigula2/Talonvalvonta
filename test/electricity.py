import time

try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print("Error importing RPi.GPIO!  This is probably because you need superuser privileges.  You can achieve this by using 'sudo' to run your script")

BCM_CHANNEL = 24

GPIO.setmode(GPIO.BCM)

GPIO.setup(BCM_CHANNEL, GPIO.IN)

i = 0;
def my_callback(channel):
    global i
    i += 1;
    print(i)

GPIO.add_event_detect(BCM_CHANNEL, GPIO.RISING, callback=my_callback)  # add rising edge detection on a channel

while True:
    time.sleep(1)

GPIO.cleanup() # Although we newer get here