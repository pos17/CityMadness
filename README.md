# **SOLI VAGANT**
<p align="center">
<img class= "center" src="./README%20Assets/Title.png" width="600">

## INTRODUCTION
Project developed for the course "Creative Programming and Computing", held in the Master degree of [Music and Acoustic Engineering](https://suono.polimi.it/), based in [Politecnico di Milano](https://www.polimi.it/). 
  The project aims at providing to the user a different way to explore a city map, using visual and sound feedbacks to guide it towards interesting points of the city

### Aim of the project
The Soli Vagant artistic installation aims to create an interactive experience based on features retrieved from real city data. These features combined with an user's input (where they want to go) create a multimodal artistic representation of the city. The project is divided in two main parts: the visual feedback which is a particle system where all the particles move as independent agents following the paths imposed by the city's streets and the path followed by the user. On regards the installation's sound design, the data sonification pursues to associate a chord progression to the user's path choices through an L-System. The soundscape gives to the user hints on how close it is to an interest point of the city, the closer it get, the clearer the soundscape becomes.

### Introduction Video

## User Guide
## Instructions
### Get started
In order to start the experience: 
1. Download the git repository
2. Open the file named with <em>sounscape.scd</em> in [SuperCollider](https://supercollider.github.io/).
3. Run the python server running the command  <em>python mdp.py</em>
4. Run the supercolider client code pressing <kbd>Ctrl</kbd> + <kbd>Enter</kbd>.
5. Run the processing code loading <em>mdp.pde</em> and run the visual system. 




### Visual feedback
The map evolves and reveals as the user explores the city. To this end, there are multiple layers of visualization

- Chaotic particles: Based on a Perlin noise, used to represent the absence of knowledge about a new place.
- Path particles: Retrieving from a geoJSON file, the particles are constraint to follow the paths near the user's location
- Wandering particles: 

As the user explores, new/interest places are suggested for him to go. This interest points allow the user to develop a large-scale knowledge of the city.
### NOTES 

### Path finding algorithm
The interest points suggestion is based on a Markov Decision Process framework, which aims to maximize a reward to the end of path finding optimization.
Basically, the MDP framework solves the equations and then gives every possible path to a certain point in the map.

<p align="center">
<img class= "center" src="./README%20Assets/mdp.jpg" width="400">

### Audio Generation

The audio generation is performed using supercollider

## Presentation files
More information about the implementation of the project are available on the [slides](/) uploaded and used as aid during the final presentation of the project Creative Programming and Technology.

## Group members
- Manuel Alejandro Jaramillo  (ManuelAlejandro.Jaramillo@mail.polimi.it)
- Juan Camilo Albarracin Sanchez  (JuanCamilo.Albarracin@mail.polimi.it)
- Marco Bernasconi  (Marco7.Bernasconi@mail.polimi.it)
- Paolo Ostan (paolo.ostan@mail.polimi.it)
