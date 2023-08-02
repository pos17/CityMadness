import json
from multiprocessing.connection import wait
import numpy as np
import matplotlib.pyplot as plt
import mdptoolbox
import scipy
import argparse
import random
import time

from pythonosc import osc_message_builder
from pythonosc import udp_client
from pythonosc import osc_server
from pythonosc import dispatcher
np.random.seed(0)
inport = 5004

outport = 1234

client = udp_client.SimpleUDPClient("127.0.0.1", outport)

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
            break
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
    client.send_message("/StartMusPath",len(MusPath))
    print("Path Started")
    #client.send_message("/MusPath",MusPath)
    msg = osc_message_builder.OscMessageBuilder(address = '/MusPath')
    for i in range(len(MusPath)):
        #client.send_message("/MusPath", "{0}".format(MusPath[i]))
        msg.add_arg(MusPath[i], arg_type='i')
        print(MusPath[i])
        #time.sleep(1)
        if i == len(MusPath)-1:
            break
    msg = msg.build()
    print("done path")
    #time.sleep(2)
    client.send(msg)
    
    #client.send_message("MusPath",MusPath)
    print("MusPath Sent")
    #time.sleep(10)
    client.send_message("/StopMusPath",0)
    print("MusPath finished")

    client.send_message("/StartShortPath",len(ShortPath))
    print("Short Path Started")
    #client.send_message("/MusPath",MusPath)
    msg2 = osc_message_builder.OscMessageBuilder(address = '/ShortPath')
    for i in range(len(ShortPath)):
        #client.send_message("/MusPath", "{0}".format(MusPath[i]))
        msg2.add_arg(ShortPath[i], arg_type='i')
        print(ShortPath[i])
        #time.sleep(1)
        if i == len(ShortPath)-1:
            break
    msg2 = msg2.build()
    print("done path short")
    #time.sleep(2)
    client.send(msg2)
    
    #client.send_message("MusPath",MusPath)
    print("ShortPath Sent")
    #time.sleep(10)
    client.send_message("/StopShortPath",0)
    print("ShortPath finished")






    #client.send_message("/StartShortPath",1)
    #print("Short Path Started")
    #for i in range(len(ShortPath)):
    #    client.send_message("/ShortPath", "{0}".format(ShortPath[i]))
        #time.sleep(1)
    #    print("Short Path: " + str(ShortPath[i]))
    #    if i == len(ShortPath)-1:
    #        break
    
    #client.send_message("/StopShortPath",0)
    #print("Short Path Stopped")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default="127.0.0.1",
        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=inport,
        help="The port the OSC server is listening on")
    args = parser.parse_args()

    f = open("graphCremona.json")
    graph = json.load(f)
    features = graph["features"]
    loadNodes(features)

    dm = distMatrix(nodes)
    maxC = getMaxC()
    tm = transMatrix(nodes,maxC)

    tm_sparse = []
    for i in range(len(tm)):
        tm_sparse.append(scipy.sparse.csr_matrix(tm[i]))

    notes = np.random.randint(12,size=len(nodes))
    
    dispatcher = dispatcher.Dispatcher()

    dispatcher.map("/start",randPathsHandler)
    dispatcher.map("/target",targetHandler)
    
    server = osc_server.ThreadingOSCUDPServer((args.ip, args.port), dispatcher)

    print("Serving on {}".format(server.server_address))
    server.serve_forever()
    

    



