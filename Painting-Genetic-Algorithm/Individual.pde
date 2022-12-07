class Individual{
  
  DNA dna;
  double fitness;
  long maxdiff = Resolution*int(Resolution/ratio)*4*255*255L;
  int Npixels =  Resolution*int(Resolution/ratio);
  //int geneCounter = 0;
  //PGraphics plot;
  Individual(DNA dna_){
    //plot = createGraphics(width/2,height);
    dna = dna_;
    
  }
  
  void fitness() { //pixel wise MSE
    tempFillGraphics();
    double diff = 0L;
    

    TempDraw.loadPixels();
    //pgImage.loadPixels();
    //int[] argb = TempDraw.pixels;
    for (int i = 0; i < Npixels; i++) {
      float rd = red(TempDraw.pixels[i]);
      float gd = green(TempDraw.pixels[i]);
      float bd = blue(TempDraw.pixels[i]);
      float ad = blue(TempDraw.pixels[i]);

      float ri = red(TempImage.pixels[i]);
      float gi = green(TempImage.pixels[i]);
      float bi = blue(TempImage.pixels[i]);
      float ai = blue(TempImage.pixels[i]);

      diff += (rd-ri)*(rd-ri)+ (gd-gi)*(gd-gi) + (bd-bi)*(bd-bi) + (ad-ai)*(ad-ai);
      //print(diff+"\n");
    }
    fitness = 1 - diff/maxdiff;
    //print(fitness+"\n");
  }
  
  void tempFillGraphics(){
    TempDraw.beginDraw();
    TempDraw.clear();
    TempDraw.background(0);
    for(int i=0;i<dna.genes.length;i++){
      dna.genes[i].plot(TempDraw);
    }
    TempDraw.endDraw();
      
  }
  
  void fillGraphics(){
    pgDraw.beginDraw();
    pgDraw.clear();
    pgDraw.background(0);
    for(int i=0;i<dna.genes.length;i++){
      dna.genes[i].display(pgDraw);
    }
    pgDraw.endDraw();
      
  }
  
  double getFitness() {
    return fitness;
  }

  DNA getDNA() {
    return dna;
  }
  
}
