from pythonosc import osc_message_builder
from pythonosc import udp_client
from pythonosc import osc_server
from pythonosc import dispatcher


outport = 57120

#client = udp_client.SimpleUDPClient("127.0.0.1", outport)

def main():
    
    inport = 5004
    outport = 57120  
    midiValue = 69
    client = udp_client.SimpleUDPClient("127.0.0.1", outport)
    client.send_message("/noteOn",midiValue)
    print("/noteOn",midiValue)
main()
