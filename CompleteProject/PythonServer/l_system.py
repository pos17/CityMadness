from ast import parse
from calendar import c
from email.mime import base
from platform import node
from re import T
import sched, time
import string
from turtle import position
import numpy as np
from tracemalloc import start
from mdp import nodes
from mdp import client

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
l_system_started = False
axiom = 'NNSSEEWW'
positionsList = []
dirList = ""
scheduler = None
maxLength = 10

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

def lSysGenerate(s, d, order):
    for i in range(order):
        s = lSysCompute(s)
    return s

def lSysCompute(s,b,d):
    d = {b: d}
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
        if c == "E":
            chordLength = tBase / 2
            playablechord=True
        elif c == "W": 
            chordLength = tBase * 2
            playablechord=True
        elif c == 'S':
            if playablechord == True:
                notes= chordToMidiNotes(scaleIndex, chordValue,baseNote)
                print(notes)
                scheduleNotes(notes,chordLength,startTime,client,scheduler)
                playablechord=False
                startTime=startTime+chordLength
                chordLength=0
            chordValue=chordValue-1  
        elif c == 'N':
            if playablechord == True:
                notes= chordToMidiNotes(scaleIndex, chordValue,baseNote)
                scheduleNotes(notes,chordLength,startTime,client,scheduler)
                playablechord=False
                startTime=startTime+chordLength
                chordLength=0
            chordValue=chordValue+1


def start_L_system():
    scheduler = sched.scheduler(time.monotonic, time.sleep)
    return scheduler
   


def update_L_system(unused_addr, currentNode):

    print("startCurrentNode")
    print(currentNode)
    print("endCurrentNode")

    updatePositionsList(positionsList,currentNode,maxLength)
    dirList = returnDirList(positionsList)
    if(l_system_started==False):
        scheduler = start_L_system()
        l_system_started = True
    iterations = 1
    char = "N"
    startingNoteMidi = 69
    tBase = 4
    baseChordPos= 0
    scaleIndex = 1
    lsysString = lSysCompute(axiom,char,dirList)#lSysGenerate(axiom, iterations)
    parseChords(lsysString, tBase,baseChordPos,scaleIndex,startingNoteMidi,client, scheduler)


def calculateDir(node1x,node1y,node2x,node2y):
    x = node2x - node1x
    y = node2y - node1y
    theta2PI = np.arctan2(x,y) * 180 / np.pi
    if(theta2PI<-(5/6)*np.pi):
        dir = "EE"
    elif(theta2PI<-(2/3)*np.pi): 
        dir = "SE"
    elif(theta2PI<-(1/3)*np.pi): 
        dir = "SS"
    elif(theta2PI<-(1/6)*np.pi): 
        dir = "SW"
    elif(theta2PI<(1/6)*np.pi): 
        dir = "WW"    
    elif(theta2PI<(1/3)*np.pi): 
        dir = "NW"    
    elif(theta2PI<(2/3)*np.pi): 
        dir = "NN"        
    elif(theta2PI<(5/6)*np.pi): 
        dir = "NE"
    else:
        dir = "EE"
    return dir
def updatePositionsList(positionsList,nextNodeIndex,listLength):
    nodeX = nodes[nextNodeIndex,1]
    nodeY = nodes[nextNodeIndex,2]
    nodePos = [nodeX,nodeY]
    positionsList.append(nodePos)
    if(len(positionsList) > listLength):
        positionsList.pop(0)
    return positionsList

def returnDirList(positionsList):
    dirList = ""
    for i in range(len(positionsList)-1):
        dirList = dirList + calculateDir(positionsList(i,1),positionsList(i,2),positionsList(i+1,1),positionsList(i+1,2))
    return dirList


def main():
    print(chordToMidiNotes(1,4,33))
    inport = 5004
    outport = 57121  
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

    axiom = 'NNSESWNENWWWEESS'
    length = 10
    angle = 60
    iterations = 5
    startingNoteMidi = 69
    tBase = 4
    baseChordPos= 0
    scaleIndex = 1

    lsysString = lSysGenerate(axiom, iterations)
    #parseNotes(lsysString,tBase,startingNoteMidi,client,scheduler)
    parseChords(lsysString, tBase,baseChordPos,scaleIndex,startingNoteMidi,client, scheduler)
    # draw(tBase, lsysString, length)

    # wn.exitonclick()
    scheduler.run()

#main()




    #print(time.time())

    #s.enter(10, 1, print_time)

    #s.enter(5, 2, print_time, argument=('positional',))

    # despite having higher priority, 'keyword' runs after 'positional' as enter() is relative

    #s.enter(5, 1, print_time, kwargs={'a': 'keyword'})

    #s.enterabs(1_650_000_000, 10, print_time, argument=("first enterabs",))

    #s.enterabs(1_650_000_000, 5, print_time, argument=("second enterabs",))

    #s.run()

    #print(time.time())
