from ast import parse
from calendar import c
from email.mime import base
from platform import node
from re import T
import sched
import time
import string
#from turtle import position
#import mdp
#from mdp import nodes
import numpy as np
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


positionsList = []
dirList = ""
maxLength = 10
inport = 5004
outport2 = 57120  
SchedStartTime = 0 


#print("client2 ok")

def sendNoteOn(midiValue,client):
    client.send_message("/noteOn",midiValue)
    print("/noteOn",midiValue)

def sendNoteOff(midiValue,client):
#    print("time: "+str(time.time()-scheduler_started_time))
    client.send_message("/noteOff",midiValue)
    print("/noteOff",midiValue)

def sendNoiseOn(unused_addr,client,arg):
    client.send_message("/noiseOn",0)
    print("/noiseOn")

def sendSNRRatio(client, value):
    client.send_message("/snrVal",value)
    print("/snrVal" + str(value))

def scheduleNotes(midiValues,length,startTime,client,scheduler):
    for i in midiValues:
        #print(i)
        scheduleNote(i,length,startTime,client,scheduler)

# eventList: 
# 0: type of event, 0 noteOn,1 noteOff, 2 schedule
# 1: event handler
# 2: relative starttime

def scheduleNote(midiValue,length,startTime,client,scheduler):
    noteOnEvent = scheduler.enter(startTime,1,sendNoteOn,argument=(midiValue,client))
    noteOffEvent = scheduler.enter(startTime+length,2,sendNoteOff,argument=(midiValue,client))

def sendTotalNoteOff(minVal, maxVal,scheduler,client):
    for midiValue in range(minVal,maxVal,1):
        scheduler.enter(0,2,sendNoteOff,argument=(midiValue,client))


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

 #notesList [midiNote,length,time]

def parseChords(s, tBase, baseChord,scaleIndex,baseNote,startingTime):
    chordValue = baseChord
    chordLength= tBase
    startTime = startingTime
    playablechord = False
    notesList = []
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
                #print(notes)
                #scheduleNotes(notes,chordLength,startTime,client,scheduler,scheduler_started_time)
                #print("note scheduled at time "+str(startTime) +  ", length "+str(chordLength))
                notesEvent = [notes,chordLength,startTime]
                notesList.append(notesEvent)
                playablechord=False
                startTime=startTime+chordLength
                chordLength=tBase
            chordValue=chordValue-1  
        elif c == 'N':
            if playablechord == True:
                notes= chordToMidiNotes(scaleIndex, chordValue,baseNote)
                #scheduleNotes(notes,chordLength,startTime,client,scheduler,scheduler_started_time)
                #print("note scheduled at time "+str(startTime) +  ", length "+str(chordLength))
                notesEvent = [notes,chordLength,startTime]
                notesList.append(notesEvent)
                playablechord=False
                startTime=startTime+chordLength
                chordLength=tBase
            chordValue=chordValue+1
    #print("startTime")
    #print(startTime)
    return [startTime,notesList]

    

def start_L_system():
    
   
    
    print("scheduler2 created ")
   
   


def update_L_system(unused_addr, things, currentNode):
    nodes = things[0][0]
    client = things[0][1]
    scheduler = things[0][2]
    endingTime = things[0][3]
    l_system_started = things[0][4]
    scheduler_started_time = things[0][5] 
    axiom = things[0][6] 
    snr = things[0][7]
    updatePositionsList(nodes, positionsList,currentNode,maxLength)
    print("positionsList: " + str(positionsList))
    dirList = returnDirList(positionsList)
    #print("dirList")
    #print(dirList)
    iterations = 1
    char = "N"
    startingNoteMidi = 69
    tBase = 2
    baseChordPos= 0
    scaleIndex = 1
    print("dirList: " + dirList + "; char: " + char +"; axiom: " + axiom)
    lsysString = lSysCompute(axiom,char,dirList)#lSysGenerate(axiom, iterations)
    print("dirList: " + dirList + "; char: " + char +"; axiom: " + lsysString)
    [endingTime,notesList] = parseChords(lsysString, tBase,baseChordPos,scaleIndex,startingNoteMidi,endingTime)
    for event in scheduler.queue:
        scheduler.cancel(event)
    print("scheduler empty: " + str(scheduler.empty()))
    sendTotalNoteOff(0,100,scheduler,client)
    endingTime = 0
    for notesEvent in notesList:
        scheduleNotes(notesEvent[0],notesEvent[1],notesEvent[2],client,scheduler)
    #print(scheduler.queue[len(scheduler.queue)-1][0])
    scheduler.enter(endingTime,3,reiterate_l_system,argument=(client,scheduler,dirList,lsysString))
    print("scheduling event at time " + str(endingTime))
    # lines for rescheduling events to increase depth of the system 
    print("l system started: " + str(l_system_started))

    # function call to set correctly signal to noise ratio
    if(snr < 10 ):
        snr += 1
        things[0][7] = snr
        sendSNRRatio(client,snr)


    if(l_system_started==False):
        print("scheduler running")
        things[0][4] = True
        things[0][5] = time.time()
        print("sched")
        print(things[0][5])
        print(scheduler.queue)
        scheduler.run()
        

def increaseCounter(counter):
    counter +=1

def reiterate_l_system(client,scheduler,dirList,axiom):
    #print(scheduler.queue)
    print("reiterate")
    startTime = 0
    char = "N"
    startingNoteMidi = 69
    tBase = 4
    baseChordPos= 0
    scaleIndex = 1
    lsysString = lSysCompute(axiom,char,dirList)#lSysGenerate(axiom, iterations)
    print("dirList: " + dirList + "; char: " + char +"; axiom: " + axiom)
    [endingTime,notesList] = parseChords(lsysString, tBase,baseChordPos,scaleIndex,startingNoteMidi,startTime)
    for notesEvent in notesList:
        scheduleNotes(notesEvent[0],notesEvent[1],notesEvent[2],client,scheduler)
        notesList.remove(notesEvent)
    #endingTime = parseChords(lsysString, tBase,baseChordPos,scaleIndex,startingNoteMidi,client, scheduler,startingTime,scheduler_started_time)
    schedulingEvent = scheduler.enter(endingTime,3,reiterate_l_system,argument=(client,scheduler,dirList,lsysString))
    print(endingTime)
    #eventList.append([2,schedulingEvent,endingTime-1])
    

def calculateDir(node1x,node1y,node2x,node2y):
    x = node2x - node1x
    y = node2y - node1y
    print("x: " + str(x) + "y: " + str(y))
    theta2PI = np.arctan2(y,x)
    print("theta2PI: " +  str(theta2PI))
    if(theta2PI<-(5/6)*np.pi):
        dir = "WW"
    elif(theta2PI<-(2/3)*np.pi): 
        dir = "SW"
    elif(theta2PI<-(1/3)*np.pi): 
        dir = "SS"
    elif(theta2PI<-(1/6)*np.pi): 
        dir = "SE"
    elif(theta2PI<(1/6)*np.pi): 
        dir = "EE"    
    elif(theta2PI<(1/3)*np.pi): 
        dir = "NE"    
    elif(theta2PI<(2/3)*np.pi): 
        dir = "NN"        
    elif(theta2PI<(5/6)*np.pi): 
        dir = "NW"
    else:
        dir = "WW"
    print("dir: " + dir)
    return dir
def updatePositionsList(nodes, positionsList,nextNodeIndex,listLength):
    #print("nodesstart")
    #print(nodes[0])
    #print("nodesend")
    nodeX = nodes[nextNodeIndex,1]
    nodeY = nodes[nextNodeIndex,2]
    nodePos = [nodeX,nodeY]
    positionsList.append(nodePos)
    if(len(positionsList) > listLength):
        positionsList.pop(0)
    return positionsList


def returnDirList(positionsList):
    dirList = ""
    #print("posList")
    #print(positionsList)
    for i in range(len(positionsList)-1):
        dirList = dirList + calculateDir(positionsList[i][0],positionsList[i][1],positionsList[i+1][0],positionsList[i+1][1])
    return dirList

"""
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

# main()




    #print(time.time())

    #s.enter(10, 1, print_time)

    #s.enter(5, 2, print_time, argument=('positional',))

    # despite having higher priority, 'keyword' runs after 'positional' as enter() is relative

    #s.enter(5, 1, print_time, kwargs={'a': 'keyword'})

    #s.enterabs(1_650_000_000, 10, print_time, argument=("first enterabs",))

    #s.enterabs(1_650_000_000, 5, print_time, argument=("second enterabs",))

    #s.run()

    #print(time.time())
"""