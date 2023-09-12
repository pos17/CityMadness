from ast import parse
from calendar import c
from email.mime import base
from re import T
import sched, time
import string
from tracemalloc import start
#import turtle
from pythonosc import osc_message_builder
from pythonosc import udp_client
from pythonosc import osc_server
from pythonosc import dispatcher

""" 
scales:

Lydian      0
Ionian      1
Myxolydian  2 
Dorian      3
Aeolian     4 
Phrygian    5
Locrian     6
MajArp      7
MinArp      8
"""

scales = [[0,2,4,6,7,9,11],[0,2,4,5,7,9,11],[0,2,4,5,7,9,10],[0,2,3,5,7,9,11],[0,2,3,5,7,8,10],[0,1,3,5,7,8,10],[0,1,3,5,6,8,10],[0,4,7],[0,3,7]]

def sendNoteOn(midiValue,client):
    client.send_message("/noteOn",midiValue)
    print("/noteOn",midiValue)

def sendNoteOff(midiValue,client):
    client.send_message("/noteOff",midiValue)
    print("/noteOff",midiValue)

def scheduleNotes(midiValues,length,startTime,client,scheduler):
    for i in midiValues:
        print(i)
        scheduleNote(i,length,startTime,client,scheduler)

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

""" 
scales:

Lydian      0
Ionian      1
Myxolydian  2 
Dorian      3
Aeolian     4 
Phrygian    5
Locrian     6
MajArp      7
MinArp      8
"""
def chordToMidiNotes(scaleIndex, chordIndex,baseNote):
    scale = scales[scaleIndex]
    notes = [scale[chordIndex%7]+baseNote,scale[(chordIndex+2)%7]+baseNote,scale[(chordIndex+4)%7]+baseNote]
    return notes
    

""" def parseNotes(s, tBase, baseNote,client,scheduler):
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
 """

def parseChords(s, tBase, baseChord,scaleIndex,baseNote,client,scheduler):
    chordValue = baseChord
    chordLength=0
    startTime = 0
    playablechord = False
    for c in s:
        if c in string.ascii_letters:
            chordLength = chordLength+tBase
            playablechord=True
        elif c == '-':
            if playablechord == True:
                notes= chordToMidiNotes(scaleIndex, chordValue,baseNote)
                print(notes)
                scheduleNotes(notes,chordLength,startTime,client,scheduler)
                playablechord=False
                startTime=startTime+chordLength
                chordLength=0
            chordValue=chordValue-1
            
        elif c == '+':
            if playablechord == True:
                notes= chordToMidiNotes(scaleIndex, chordValue,baseNote)
                scheduleNotes(notes,chordLength,startTime,client,scheduler)
                playablechord=False
                startTime=startTime+chordLength
                chordLength=0
            chordValue=chordValue+1




def main():
    print(chordToMidiNotes(1,4,33))
    inport = 5004
    outport = 57120  
    client = udp_client.SimpleUDPClient("127.0.0.1", outport)
    scheduler = sched.scheduler(time.monotonic, time.sleep)
    Scale = "C"
    
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
    baseChordPos= 0
    scaleIndex = 1

    lsysString = lSysGenerate(axiom, iterations)
    #parseNotes(lsysString,tBase,startingNoteMidi,client,scheduler)
    parseChords(lsysString, tBase,baseChordPos,scaleIndex,startingNoteMidi,client, scheduler)
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
