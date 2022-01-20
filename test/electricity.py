import time
import RPi.GPIO as GPIO

# Configurations
BCM_CHANNEL = 24
RECORDING_INTERVAL_SECONDS = 5.0
PULSES_PER_KWH = 10000

# Helpers
SECONDS_PER_HOUR = 60*60

# Prepare channel
GPIO.setmode(GPIO.BCM)
GPIO.setup(BCM_CHANNEL, GPIO.IN)

# Prepare callback for counting pulses
pulseCount = 0
def pulseCounterInterrupt(channel):
    global pulseCount
    pulseCount += 1

# Start listening
GPIO.add_event_detect(BCM_CHANNEL, GPIO.RISING, callback=pulseCounterInterrupt)  # add rising edge detection on a channel

# Idle in main thread
print(f"Start energy reading on {RECORDING_INTERVAL_SECONDS}s refresh rate from pin GPIO{BCM_CHANNEL}")
totalPulses = 0
while True:
    # Sleep for interval (note: this is not accurate since all the steps in while after this should reduce the sleep amount, not sure how relevant this is)
    time.sleep(RECORDING_INTERVAL_SECONDS)
    
    # Capture last interval pulse count and zero the counter
    lastIntervalPulses = pulseCount
    pulseCount = 0
    totalPulses += lastIntervalPulses
    
    # Calculate current power
    pulseDistance = RECORDING_INTERVAL_SECONDS / lastIntervalPulses # Time difference between pulses
    power = SECONDS_PER_HOUR / (pulseDistance * PULSES_PER_KWH)

    # Calculate total energy consuption since start of script
    totalEnergy = totalPulses / PULSES_PER_KWH

    # TODO: Are the calculations correct? Waterheater drew ~2kW and that made power jump from 2kW -> 6kW
    # TODO: Full solution here? seems quite complex https://github.com/ivyleavedtoadflax/elec dockerfile could at least be utilized

    # Print details
    print(f"Power: {power:0.1f} kW     Total: {totalEnergy:0.3f} kWh")



 # For completeness although we newer get here
GPIO.cleanup()


