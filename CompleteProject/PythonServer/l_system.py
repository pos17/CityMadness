from ast import parse
import sched, time
import string
from tracemalloc import start
import turtle
from pythonosc import osc_message_builder
from pythonosc import udp_client
from pythonosc import osc_server
from pythonosc import dispatcher

def sendNoteOn(midiValue,client):
    client.send_message("/noteOn",midiValue)
    print("/noteOn",midiValue)

def sendNoteOff(midiValue,client):
    client.send_message("/noteOff",midiValue)
    print("/noteOff",midiValue)

def scheduleNote(midiValue,length,startTime,client,scheduler):
    scheduler.enter(startTime,1,sendNoteOn,argument=(midiValue,client))
    scheduler.enter(startTime+length,1,sendNoteOff,argument=(midiValue,client))

def lSysGenerate(s, order):
    for i in range(order):
        s = lSysCompute(s)
    return s

def lSysCompute(s):
    d = {'A': 'AA-A++A-AAA'}
    return ''.join([d.get(c) or c for c in s])



def draw(t, s, length, angle):

    for c in s:
        if c in string.ascii_letters:
            t.forward(length)
        elif c == '-':
            t.left(angle)
        elif c == '+':
            t.right(angle)

def parseNotes(s, tBase, baseNote,client,scheduler):
    noteValue = baseNote
    noteLength=0
    startTime = 0
    playableNote = False
    for c in s:
        if c in string.ascii_letters:
            noteLength = noteLength+tBase
            playableNote=True
        elif c == '-':
            if playableNote == True:
                scheduleNote(noteValue,noteLength,startTime,client,scheduler)
                playableNote=False
                startTime=startTime+noteLength
            noteLength=0
            noteValue=noteValue-1
            
        elif c == '+':
            if playableNote == True:
                scheduleNote(noteValue,noteLength,startTime,client,scheduler)
                playableNote=False
                startTime=startTime+noteLength
            noteLength=0
            noteLength=0
            noteValue=noteValue+1



def main():
    inport = 5004
    outport = 57120  
    client = udp_client.SimpleUDPClient("127.0.0.1", outport)
    scheduler = sched.scheduler(time.monotonic, time.sleep)

    # t = turtle.Turtle()
    # wn = turtle.Screen()
    # wn.bgcolor('black')

    # t.color('orange')
    # t.pensize(1)
    # t.penup()
    # t.setpos(-250, -250)
    # t.pendown()
    # t.speed(0)

    axiom = 'A++-A-A+AAA'
    length = 10
    angle = 60
    iterations = 5
    startingNoteMidi = 69
    tBase = 2
    lsysString = lSysGenerate(axiom, iterations)
    parseNotes(lsysString,tBase,startingNoteMidi,client,scheduler)
    # draw(tBase, lsysString, length)

    # wn.exitonclick()
    scheduler.run()

main()


    #print(time.time())

    #s.enter(10, 1, print_time)

    #s.enter(5, 2, print_time, argument=('positional',))

    # despite having higher priority, 'keyword' runs after 'positional' as enter() is relative

    #s.enter(5, 1, print_time, kwargs={'a': 'keyword'})

    #s.enterabs(1_650_000_000, 10, print_time, argument=("first enterabs",))

    #s.enterabs(1_650_000_000, 5, print_time, argument=("second enterabs",))

    #s.run()

    #print(time.time())
