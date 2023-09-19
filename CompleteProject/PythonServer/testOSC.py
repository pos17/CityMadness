from pythonosc import osc_message_builder
from pythonosc import udp_client
from pythonosc import osc_server
from pythonosc import dispatcher
import sched, time


outport = 57120

#client = udp_client.SimpleUDPClient("127.0.0.1", outport)

def main():
    
    inport = 5004
    outport = 57120  
    midiValue = 69
    client = udp_client.SimpleUDPClient("127.0.0.1", outport)
    client.send_message("/noteOn",midiValue)
    print("/noteOn",midiValue)
    scheduler = sched.scheduler(time.monotonic, time.sleep)
    noteOnEvent = scheduler.enter(5,1,print,argument=("midiValue,client"))
    print(scheduler.queue)
    scheduler.cancel(scheduler.queue[0])
    print(scheduler.queue)
main()
