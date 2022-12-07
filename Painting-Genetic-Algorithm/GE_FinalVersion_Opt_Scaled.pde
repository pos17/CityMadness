//Individual ind;
PGraphics pgImage, pgDraw;
PGraphics TempDraw, TempImage;
PImage myImage, workImage;
//DNA dna1;
int NPol=4;
int numPol=150;
float selectAmount = 0.15;
float mutateAmount = 0.15;
float mutationRate = 0.01;
int PopSize = 50;
int Resolution = 150;
float ratio;
Population population;


void settings() {
  myImage = loadImage("images/eiffel.jpg");
  //println(img.width, img.height);
  ratio = (float)myImage.width/(float)myImage.height;
  //print(int(720/ratio));
  size(720*2, int(720/ratio), P2D);
  //frameRate(60);
  smooth(8);
}

void setup() {
  //size(740,300,P2D);
  frameRate(60);
  //smooth(8);

  population = new Population(mutationRate, PopSize);


  //dna1 = new DNA();
  pgImage = createGraphics(width/2, height);
  pgDraw = createGraphics(width/2, height, P2D);

  TempDraw = createGraphics(Resolution, int(Resolution/ratio), P2D);
  TempImage = createGraphics(Resolution, int(Resolution/ratio));

  pgDraw.smooth(8);
  TempDraw.smooth(8);

  //myImage = loadImage("images/city.jpg");

  workImage = myImage.get();

  myImage.resize(width/2, height);
  workImage.resize(Resolution, int(Resolution/ratio));

  TempDraw.colorMode(RGB, 255, 255, 255, 255);
  pgDraw.colorMode(RGB, 255, 255, 255, 255);
  pgImage.colorMode(RGB, 255, 255, 255, 255);
  TempImage.colorMode(RGB, 255, 255, 255, 255);

  TempImage.beginDraw();
  TempImage.image(workImage, 0, 0);
  TempImage.endDraw();
  TempImage.loadPixels();

  pgImage.beginDraw();
  pgImage.image(myImage, 0, 0);
  pgImage.endDraw();
  image(pgImage, 0, 0);
  pgImage.loadPixels();
}

void draw() {


  //Evolve
  population.fitness();
  population.selection();
  population.reproduction();

  //Draw best individual
  //Individual best = population.getMaxFitnessInd();
  population.best.fillGraphics();
  print("Gen:" +population.generations + " fit:" + population.best.fitness+"\n");
  image(pgDraw, width/2, 0);
  if (population.best.fitness > 0.993 ) {
    myImage = loadImage("images/duomo.jpg");
    workImage = myImage.get();
    myImage.resize(width/2, height);
    workImage.resize(Resolution, int(Resolution/ratio));

    TempImage.beginDraw();
    TempImage.image(workImage, 0, 0);
    TempImage.endDraw();
    TempImage.loadPixels();

    pgImage.beginDraw();
    pgImage.image(myImage, 0, 0);
    pgImage.endDraw();
    image(pgImage, 0, 0);
    pgImage.loadPixels();
  }

  //delay(500);
  saveFrame("output/image####.png");
}
