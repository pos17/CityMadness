import oscP5.*;
import netP5.*;
String value1;
String value2;

// To forskellige OSC objekter, til at sende hver deres besked:
OscP5 oscP5;
OscP5 oscP52;
NetAddress myRemoteLocation;

void setup() {
  size(400,400);
  frameRate(25);
  oscP5 = new OscP5(this,1236);
  oscP52 = new OscP5(this,1236);

  myRemoteLocation = new NetAddress("127.0.0.1", 5010);
}

void draw() {
  background(0);
  
}

void keyPressed() {
  OscMessage myMessage = new OscMessage("/target");
  myMessage.add(789);
  oscP52.send(myMessage, myRemoteLocation);
  print("sender target");
}

void mousePressed(){
  OscMessage myMessage = new OscMessage("/start");
  
  /* Man kan tilføje int, float, text, byte OG arrays*/
  // Denne beskedID indeholder 3 beskeder, hvilket skal tages i mente
  // for den modtagende handler-funktion
  myMessage.add(500);
  /* Hvad der sendes, og hvor til */
  oscP5.send(myMessage, myRemoteLocation);
  print("sender start");
}

void oscEvent(OscMessage theOscMessage) {
  // Således ser det ud for modtagelse af kun én OSC besked:
  if(theOscMessage.checkAddrPattern("/MusPath")==true) {
    value1 = theOscMessage.get(0).stringValue();
    print(" Mus: "+value1 +"\n");
  }
  
  // Man kan også tjekke på OSC-ID og laver handlinger ud fra hvert ID:
  if(theOscMessage.checkAddrPattern("/ShortPath")==true) {
    value2 = theOscMessage.get(0).stringValue();
    print(" Short: "+value2+"\n");
   }
}
