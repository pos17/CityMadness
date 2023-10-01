import json
from multiprocessing.connection import wait
import numpy as np
from position import scheduleOSCPathsToInterestNode, scheduleOSCPathsFirstNode
from position import ImageToMap
import mdptoolbox
import scipy
import argparse
import random
import time
import l_system
import sched
import position

from pythonosc import osc_message_builder
from pythonosc import udp_client
from pythonosc import osc_server
from pythonosc import dispatcher
np.random.seed(0)
inport = 5005
global nodes
outport = 1235
outport2 = 57120
noteOnList =[]
noteOffList = []
client = udp_client.SimpleUDPClient("127.0.0.1", outport)
client2 = udp_client.SimpleUDPClient("127.0.0.1", outport2)
#scheduler for midi OSC notes
scheduler = sched.scheduler(time.monotonic, time.sleep)
#scheduler for interestPaths update
scheduler2 = sched.scheduler(time.monotonic, time.sleep)
scheduler3 = sched.scheduler(time.monotonic, time.sleep)
l_system_started = False
scheduler_started_time = 0 
endingTime = 0
countSecs = 0
axiom = 'NWSWSENNNEEEWWNW'
snr = 0 #value that specifies the value of noise wrt the value of audio signal
imageMap = None


def NormalizeMusic(data):
    return (((data - np.min(data)) / (np.max(data) - np.min(data))) - 0.5)*2

def NormalizeDist(data):
    return (data - np.min(data)) / (np.max(data) - np.min(data))

def dist(node1,node2):
    dist = (nodes[node2,1]-nodes[node1,1])**2 + (nodes[node2,2]-nodes[node1,2])**2
    return dist**(1/2.)

def distReward(dist,n):
    return -1*(dist-1)**n

def musicalReward(notes,node1, node2):
    #weights = np.array([7,4,12,5,11,9,1,10,3,6,2,8])
    #weights = weights/sum(weights)
    
    #weights = np.array([6,1,10,0,10,6,-8,8,-4,0,-4,2])
    #weights = NormalizeMusic(weights)
    
    #weights = np.array([0,-1,0.8,-3,0.7,0.5,-10,0.5,-3,0.3,-5,0.4])
    weights = np.array([0.2,-4,0.2,-4,0.2,0.2,-4,0.2,-4,0.2,-4,0.2])
    note1 = notes[node1]
    note2 = notes[node2]
    interv = abs(note1-note2)
    w = weights[interv]
    return w

def distMatrix(nodes):
    distM = np.zeros((len(nodes),len(nodes)))
    for i in range(len(nodes)):
        for j in range(len(nodes)):
            distM[i,j] = dist(i,j)
    distM = NormalizeDist(distM)
    return distM

def transMatrix(nodes, maxC):
    transMatrix = np.zeros((maxC,len(nodes),len(nodes)))
    for j in range(len(nodes)):
        for n in range(maxC):
            if len(nodes[:,3][j]) == n:
                for m in range(maxC-n):
                    transMatrix[maxC-m-1,j,j] = 1
                    
            
        for i in range(len(nodes[:,3][j])):
            #print(i,j)
            transMatrix[i,j,nodes[:,3][j][i]] = 1
    return transMatrix       

def reward(nodes, target, music, dist, final, maxC, notes, dm):
    rewardMatrix  = np.ones((len(nodes),maxC))
    rewardMatrix = rewardMatrix*-1
    for i in range(len(nodes)):
        for n in range(maxC):
            if len(nodes[:,3][i]) == n:
                for m in range(maxC-n):
                    rewardMatrix[i,maxC-m-1] = -100
            #rewardMatrix[i,0] = -100
            #rewardMatrix[i,1] = -100
            #rewardMatrix[i,2] = -100
            #rewardMatrix[i,3] = -100
        for j in range(len(nodes[:,3][i])):
            if nodes[:,3][i][j] == target:
                rewardMatrix[i,j] = final
            rewardMatrix[i,j] += musicalReward(notes, i, nodes[:,3][i][j])*music
            rewardMatrix[i,j] += distReward(dm[nodes[:,3][i][j],target],15)
            rewardMatrix[i,j] -= dm[i,nodes[:,3][i][j]]*dist
            
    return rewardMatrix

def loadNodes(features):
    global nodes 
    nodes = []
    for i in range(len(features)):
        if features[i]["geometry"]["type"] == "Point":

            nodes.append ([i,features[i]["geometry"]["coordinates"][0],features[i]["geometry"]["coordinates"][1],[]])
    for i in range(len(features)):
        if features[i]["geometry"]["type"] == "LineString":
            source = features[i]["src"] - 1
            target = features[i]["tgt"] - 1
            print(str(source) + ", " + str(target))
            nodes[source][3].append(target)
            nodes[target][3].append(source)
            print(target)
    nodes = np.array(nodes, dtype=object)
    nodes.shape

def getPath(start, target, policy):
    now = start
    steps = [now]
    counter = 0
    while now != target:
        now = nodes[now,3][policy[now]]
        #print(now)
        steps.append(now)
        counter += 1
        if counter > 500:
            print("path not possible")
            return None
    return steps

def getMaxC():
    maxC = 0
    for i in range(len(nodes)):
        if len(nodes[:,3][i]) > maxC:
            maxC = len(nodes[:,3][i])
    return maxC

def targetHandler(unused_addr, target):
    print("targetHandler")
    print(target)
    #target = 508
    
    r_shortest = reward(nodes,target,0,1,5,maxC,notes,dm)
    ql_shortest = mdptoolbox.mdp.RelativeValueIteration(tm_sparse, r_shortest, 0.99)
    #ql_shortest.setVerbose()
    ql_shortest.run()
    print("targetHandler2")
    r_musical = reward(nodes,target,2,0,1,maxC,notes,dm)
    ql_musical = mdptoolbox.mdp.RelativeValueIteration(tm_sparse, r_musical, 0.99)
    #ql_musical.setVerbose()
    ql_musical.run()
    print("targetHandler3")
    global pol_shortest
    pol_shortest= ql_shortest.policy
    global pol_musical
    pol_musical= ql_musical.policy
    global targetG
    targetG = target
    print("target: " + str(target))

    print("generating optimal paths")
    pathSender()
    print("finished")

def randPathsHandler(unused_addr, start):
    print("RandHandler")
    global startG
    startG = start
    lenpath = 3
    randPath = []
    randPath.append(start)
    print("generating random path")
    for i in range (lenpath):
        rand = random.choice(nodes[randPath[i]][3])
        while (rand in randPath):
            rand = random.choice(nodes[randPath[i]][3])
        randPath.append(random.choice(nodes[randPath[i]][3]))

    msg = osc_message_builder.OscMessageBuilder(address = '/RandPath1')
    msg.add_arg(lenpath, arg_type='i')
    for i in range(len(randPath)):
        msg.add_arg(randPath[i], arg_type='i')
        print(randPath[i])
    msg = msg.build()
    client.send(msg)
    print("random path sent")

# def startHandler(unused_addr, start):
#     time.sleep(7)
#     print("startHandler")
#     print("start: " + str(start) )
#     print("targetG: "+str(targetG))
#     steps_ = getPath(start, targetG, pol_shortest)
#     steps = getPath(start, targetG, pol_musical)


#     #MusPath = notes[steps]
#     #ShortPath = notes[steps_]
#     MusPath = steps
#     ShortPath = steps_
#     client.send_message("/StartMusPath",len(MusPath))
#     print("Path Started")
#     #client.send_message("/MusPath",MusPath)
#     msg = osc_message_builder.OscMessageBuilder(address = '/MusPath')
#     for i in range(len(MusPath)):
#         #client.send_message("/MusPath", "{0}".format(MusPath[i]))
#         msg.add_arg(MusPath[i], arg_type='i')
#         print(MusPath[i])
#         #time.sleep(1)
#         if i == len(MusPath)-1:
#             break
#     msg = msg.build()
#     print("done path")
#     #time.sleep(2)
#     client.send(msg)
    
#     #client.send_message("MusPath",MusPath)
#     print("MusPath Sent")
#     #time.sleep(10)
#     client.send_message("/StopMusPath",0)
#     print("MusPath finished")

def interestPlaces(interestNodes, maxC, notes, dm, tm_sparse):
    pol_shortest = []
    for i in range(len(interestNodes)):
        r_shortest = reward(nodes,interestNodes[i],0,1,5, maxC, notes, dm)
        ql_shortest = mdptoolbox.mdp.RelativeValueIteration(tm_sparse, r_shortest, 0.99)
        ql_shortest.run()
        pol_shortest.append(ql_shortest.policy)
    return pol_shortest

def pathSender():
    time.sleep(7)
    print("startPathSender")
    print("start: " + str(startG) )
    print("targetG: "+str(targetG))
    steps_ = getPath(startG, targetG, pol_shortest)
    steps = getPath(startG, targetG, pol_musical)


    #MusPath = notes[steps]
    #ShortPath = notes[steps_]
    MusPath = steps
    ShortPath = steps_

    
    musPathMsg = osc_message_builder.OscMessageBuilder(address = '/MusPath')
    musPathMsg.add_arg(len(MusPath), arg_type='i')
    print("Music Path:")
    for i in range(len(MusPath)):
        #client.send_message("/MusPath", "{0}".format(MusPath[i]))
        musPathMsg.add_arg(MusPath[i], arg_type='i')
        print(MusPath[i])
        #time.sleep(1)
        if i == len(MusPath)-1:
            break
    musPathMsg = musPathMsg.build()
    client.send(musPathMsg)
    print("End Music Path")


    shortPathMsg = osc_message_builder.OscMessageBuilder(address = '/ShortPath')
    shortPathMsg.add_arg(len(ShortPath), arg_type='i')
    print("Short Path:")
    for i in range(len(ShortPath)):
        shortPathMsg.add_arg(ShortPath[i], arg_type='i')
        print(ShortPath[i])
        #time.sleep(1)
        if i == len(ShortPath)-1:
            break
    shortPathMsg = shortPathMsg.build()
    client.send(shortPathMsg)
    print("End Short Path")

def pathHandler(unused_addr, currentNode):
    print("Path Handler")
    print("Retrieving neighboor nodes")
    msg = osc_message_builder.OscMessageBuilder(address = '/nextNodes')
    msg.add_arg(len(nodes[currentNode][3]), arg_type='i')
    for i in range(len(nodes[currentNode][3])):
        msg.add_arg(nodes[currentNode][3][i], arg_type='i')
        print(nodes[currentNode][3][i])
    msg = msg.build()
    client.send(msg)
    print("neighboor nodes sent")

def interestPathHandler(unused_addr, currentNode):
    global interestNodes
    print(interestNodes)
    # steps = []
    # for i in range(len(interestNodes)):
    #     steps.append( getPath(currentNode, interestNodes[i], interest_pol))
    # msg = osc_message_builder.OscMessageBuilder(address = '/interestPath1')
    # msg.add_arg(len(steps[0]), arg_type='i')
    # for i in range(len(steps[0])):
    #     msg.add_arg(steps[0][i], arg_type='i')
    #     #print(nodes[currentNode][3][i])
    # msg = msg.build()
    # client.send(msg)

    # msg = osc_message_builder.OscMessageBuilder(address = '/interestPath2')
    # msg.add_arg(len(steps[1]), arg_type='i')
    # for i in range(len(steps[1])):
    #     msg.add_arg(steps[1][i], arg_type='i')
    #     #print(nodes[currentNode][3][i])
    # msg = msg.build()
    # client.send(msg)

    # msg = osc_message_builder.OscMessageBuilder(address = '/interestPath3')
    # msg.add_arg(len(steps[2]), arg_type='i')
    # for i in range(len(steps[2])):
    #     msg.add_arg(steps[2][i], arg_type='i')
    #     #print(nodes[currentNode][3][i])
    # msg = msg.build()
    # client.send(msg)
    #check if there are still interest points
    if interestNodes == []:
        print("There are no more interest places to reach")
        msg = osc_message_builder.OscMessageBuilder(address = '/interestPath')
        msg.add_arg(-1, arg_type='i')
        msg = msg.build()
        client.send(msg)
    else:
        
        # check if interest is reached
        for i in range(len(interestNodes)):
            if dm[currentNode, interestNodes[i]] == 0:
                print("interest point reached")
                del interestNodes[i]
                del interest_pol[i]
                print(interestNodes)
                break

        if interestNodes == []:
            print("There are no more interest places to reach")
            msg = osc_message_builder.OscMessageBuilder(address = '/interestPath')
            msg.add_arg(-1, arg_type='i')
            msg = msg.build()
            client.send(msg)
        else:
            # send next node for closer interest
            min_dist = 9999
            for i in range(len(interestNodes)):
                this_dist = dm[currentNode, interestNodes[i]]
                if this_dist < min_dist:
                    min_dist = this_dist
                    closer_interest = i
            #print("closer interest:", interestNodes[closer_interest])
            #print(interest_pol[closer_interest])
            interest_path = getPath(currentNode, interestNodes[closer_interest], interest_pol[closer_interest])
            msg = osc_message_builder.OscMessageBuilder(address = '/interestPath')
            msg.add_arg(interestNodes[closer_interest], arg_type='i')
            msg.add_arg(len(interest_path),arg_type='i')
            for node in interest_path:
                msg.add_arg(node, arg_type='i')
            print(interest_path)
            print(interest_path)
            msg = msg.build()
            client.send(msg)


# def interestNodeDistance(unused_addr, things, currentNode):
#     interest_point_list = things[0][0]
#     client = things[0][1]
#     max_dist = 0.02
    
#     to_send = [0,0,0,0,0]
#     in_circle = False
#     for i in range(len(interest_point_list)):
#         if(dm[currentNode,interest_point_list[i]] < max_dist):
#             percDist = dm[currentNode,interest_point_list[i]]/max_dist
#             to_send[i] = 1-percDist
#             in_circle = True
#     if(in_circle==False):
#         to_send[4] = 1
#     max_toSend = max(to_send)
#     for i in range(len(to_send)):
#         if to_send[i] < max_toSend:
#             to_send[i] = 0
        
    
#     send_interest_node_distance(to_send,client)

def send_interest_node_distance(to_send,client):
    print("to_send")
    print(to_send)
    client.send_message("/scMix",to_send)

def interestZonePaths():
    global interestNodes
    print(interestNodes)
    #startNodes = [[],[],[]]
    startNodes = [[] for _ in range(len(interestNodes))]
    for i in range(len(interestNodes)):
        for j in range(len(nodes)):
            if dm[interestNodes[i],j] < 0.01: #and dm[i,j] > 0.2:
                startNodes[i].append(j)
    #print("START NODES")
    #print(startNodes[0].__len__())

    #print("printing start nodes")
    #print(startNodes)
    #print("end of start nodes")

    steps = [[] for _ in range(len(startNodes))]

    #print(steps)
    for i in range(len(startNodes)):
        for j in range(len(startNodes[i])):
            path = getPath(startNodes[i][j], interestNodes[i], interest_pol[i])
            if path is not None:
                path.reverse()
                steps[i].append(path)

  
    return steps
    

def resetHandler(unused_addr):
    global interestNodes
    global interest_pol
    # resetting scheduler
    while len(scheduler.queue) >0:

        scheduler.cancel(scheduler.queue[0])
    # resetting scheduler 2
    while len(scheduler.queue) >0:
        scheduler.cancel(scheduler.queue[0])
    # resetting l_system
    l_system.dirList = ""
    l_system.positionsList = []
    l_system.SchedStartTime = 0
    global axiom 
    axiom = 'NWSWSENNNEEEWWNW'
    global l_system_started
    l_system_started = False
    global snr
    snr = 0 
    #interestNodes = [1013, 340, 1428, 1594]
    interestNodes = [715, 1676, 196, 1731]
    interest_pol = interestPlaces(interestNodes, maxC, notes, dm, tm_sparse)
    print(interestNodes)

"""
def goalHandler(unused_addr, list, currentNode):
    for i in range(len(list[1])):
        if currentNode == list[1][i]:
            paths = list[0][i]
            print(paths)
            ### ADD FUNCTION HERE
            scheduleOSCPathsToInterestNode(paths,client)
"""
def goalHandler(unused_addr, things, currentNode):
    myinterestNodes = things[0][1]
    list = things[0][0]
    client = things[0][2]
    client2 = things[0][3]
    print("my interest nodes")
    print(myinterestNodes)
    for i in range(len(myinterestNodes)):
        if currentNode == myinterestNodes[i]:
            print("found correct node!!!")
            paths = list[i]
            print(paths)
            ### ADD FUNCTION HERE
            
            scheduleOSCPathsToInterestNode(paths,client,scheduler2)

def nNearestNodes():
    Nodes = [[] for _ in range(len(interestNodes))]
    distances = [[] for _ in range(len(interestNodes))]
    for i in range(len(nodes)):
        dist = 999
        for j in range(len(interestNodes)):
            if dm[interestNodes[j],i] < dist: #and dm[i,j] > 0.2:
                closer = j
                dist = dm[interestNodes[j],i]
        Nodes[closer].append(i)
        distances[closer].append(dm[interestNodes[closer],i])
    sorted_nodes = []
    sorted_dist = []
    for i in range(len(distances)):
        #print("MINDISTR")
        #print(min(distances[i]))
        distances[i] = (distances[i] - min(distances[i])) / ( max(distances[i]) - min(distances[i]))
    for i in range(len(distances)):
        pairs = list(zip(distances[i], Nodes[i]))
        sorted_pairs = sorted(pairs)
        sorted_list1 = [pair[1] for pair in sorted_pairs]
        sorted_list2 = [pair[0] for pair in sorted_pairs]
        #print("SORTED LIST")
        #print(sorted_list.__len__())
        sorted_nodes.append(sorted_list1)
        sorted_dist.append(sorted_list2)
    for i in range(len(sorted_nodes)):
        if 1013 in sorted_nodes[i]:
            index = sorted_nodes[i].index(1013)
            #print("DIST0000")
            #print(sorted_dist[i][index])
    return sorted_nodes, sorted_dist

def nNearestNodesHandler(unused_addr, things  ,currentNode):
    mynodes = things[0][0]
    myinterestNodes = things[0][1]
    client = things[0][2]
    scheduler2 = things[0][3]
    client2 = things[0][4]
    print("CURRENT NODE")
    print(currentNode)
    for i in range(len(mynodes)):
        if currentNode == myinterestNodes[i]:
            nearestNodes = mynodes[i]
            # print("printing nearest nodes")
            # print(nearestNodes)
            conections = [[] for _ in range(len(nearestNodes))]
            for i in range(len(conections)):
                conections[i].append(nearestNodes[i])
                # print("CHECKING")
                # print(nearestNodes)
                for j in range(len(nodes[nearestNodes[i]][3])):
                    conections[i].append(nodes[nearestNodes[i]][3][j])
            #print("ciccia")
            sendPointArrivalFeedback(client2)
            scheduleOSCPathsToInterestNode(conections,client,scheduler2)
            
            #print("printing conecctions")
            print(conections)

def firstPathHandler(unused_addr, things,  currentNodeFirst):
    client = things[0][0]
    schedul = things[0][1]
    nearNodes = []
    for j in range(len(nodes)):
        if dm[currentNodeFirst,j] < 0.01: #and dm[i,j] > 0.2:
            nearNodes.append(j)

    conections = [[] for _ in range(len(nearNodes))]
    for i in range(len(conections)):
        conections[i].append(nearNodes[i])
        # print("CHECKING")
        # print(nearestNodes)
        for j in range(len(nodes[nearNodes[i]][3])):
            conections[i].append(nodes[nearNodes[i]][3][j])
    scheduleOSCPathsFirstNode(conections, client, schedul)
    
def synthHandler(unused_addr, things,  currentNode):
    myNodes = things[0][2]
    distances = things[0][0]
    client = things[0][1]
    myInterestNodes = things[0][3]
    to_send = [[] for _ in range(len(distances))]
    for i in range(len(distances)):
        if currentNode in myNodes[i]:
            #index = myNodes[i].index(currentNode)
            #to_send[i] = 1 - distances[i][index]
            dist = 999
            for j in range(len(myInterestNodes)):
                if i != j and dm[myInterestNodes[i], myInterestNodes[j]] < dist:
                    dist = dm[myInterestNodes[i], myInterestNodes[j]]
                    closer = myInterestNodes[j]
            to_send[i] = dm[currentNode, myInterestNodes[i]]/dm[currentNode, closer]
                    
        else:
            to_send[i] = 0
    print("TOSENT")
    print(to_send)
    send_interest_node_distance(to_send,client)
    

def forwardOSCMessage(used_addr, things, args):
    myclient = things[0][0]
    myclient.send_message(used_addr,args)
    #print("/noteOn",midiValue)

def sendPointArrivalFeedback(myclient): 
    myclient.send_message("/pointArrival",0)
    print("/pointArrival")
    #print("/noteOn",midiValue)

"""
def scheduleFadeInOutDryWetValues(initVal,finalVal,timeRate,increaseRate,myClient,myScheduler): 
    val = initVal
    delay = 0
    while initVal <finalVal:
        val = val +increaseRate
        delay = delay + timeRate
        myScheduler.enter(delay,4,sendPath,argument=(path,client))
        delay += 0.0001
        #print(delay)
    myScheduler.run()

def sendFadeInOutDryWetValues(val,myClient): 
     myclient.send_message("/pointArrival",0)
"""



if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default="127.0.0.1",
        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=inport,
        help="The port the OSC server is listening on")
    args = parser.parse_args()

    f = open("graphCremonaLarge.json")
    graph = json.load(f)
    features = graph["features"]
    loadNodes(features)
    global dm
    dm = distMatrix(nodes)
    #print("DMDMDMDM")
    #print(dm)
    global maxC
    maxC = getMaxC()
    global notes
    notes = np.random.randint(12,size=len(nodes))
    tm = transMatrix(nodes,maxC)
    global tm_sparse
    tm_sparse = []
    for i in range(len(tm)):
        tm_sparse.append(scipy.sparse.csr_matrix(tm[i]))
    global interestNodes
    #interestNodes = [1013, 340, 1428, 1594]  # [877, 73, 137, 1698]
    #interestNodes = [877, 73, 137, 1698]
    interestNodes = [715, 1676, 196, 1731]
    global interestNodes2
    #interestNodes2 = [1013, 340, 1428, 1594]
    #interestNodes2 = [877, 73, 137, 1698]
    interestNodes2 = [715, 1676, 196, 1731]
    global interest_pol
    interest_pol = interestPlaces(interestNodes, maxC, notes, dm, tm_sparse)
    global steps
    steps = interestZonePaths()
    global nNodes
    nNodes, nDist = nNearestNodes()

    print("MAXDIST")
    print(max(nDist[1]))
    print("MINDIST")
    print(min(nDist[1]))
    dispatcher = dispatcher.Dispatcher()

    imageMap = ImageToMap("assets/COLORMAPTEST.png",[(10.060950707625352,
          45.154113135481765),(9.994003334686766,
          45.12628845363338)])
    imageMap.find_black_pixels()
    print(imageMap.image_reference_points) 
    scheduler2.run()
    #imageMap.plot_image_with_reference_points() 
    #map_coordinates_to_query = (10.01111,45.131111)  # Corresponding map coordinates
    #rgb_value = imageMap.get_rgb_at_map_coordinates(map_coordinates_to_query)
    #print("RGB Value:", rgb_value)
    # dispatcher.map("/start",randPathsHandler)
    # dispatcher.map("/target",targetHandler)
    dispatcher.map("/reset", resetHandler)
    dispatcher.map("/currentNode", pathHandler)
    dispatcher.map("/currentNodeFirst", firstPathHandler, [client,scheduler2])
    dispatcher.map("/currentNode", interestPathHandler)
    dispatcher.map("/currentNode", synthHandler, [nDist,client,nNodes, interestNodes2])
    dispatcher.map("/currentNode", nNearestNodesHandler, [nNodes, interestNodes2,client,scheduler2,client2])
    #dispatcher.map("/currentNode", interestNodeDistance,[interestNodes2,client2])
    #dispatcher.map("/currentNode", goalHandler, [steps,interestNodes2,client, scheduler2])
    dispatcher.map("/currentNode", l_system.update_L_system, [nodes,client2,scheduler,endingTime,l_system_started,scheduler_started_time,axiom,snr,imageMap]) #function for updating l_system
    dispatcher.map("/reset", l_system.sendNoiseOn, [client2])
    dispatcher.map("/fcVal", forwardOSCMessage, [client2])
    dispatcher.map("/musicVol", forwardOSCMessage, [client2])
    dispatcher.map("/synthAgit", forwardOSCMessage, [client2])
    dispatcher.map("/scVol", forwardOSCMessage, [client2])
    dispatcher.map("/grainVol", forwardOSCMessage, [client2])
    server = osc_server.ThreadingOSCUDPServer((args.ip, args.port), dispatcher)
    #print("These are the nodes")
    #print(nodes)
    print("Serving on {}".format(server.server_address))
    server.serve_forever()
    
    

    



