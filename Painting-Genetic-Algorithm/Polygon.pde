class Polygon{

  float[] vX;
  float[] vY;
  float alpha;
  //int N;
  float R,G,B;
  Polygon(float[] vX, float[] vY, float R, float G, float B, float alpha)
  {

    this.R = R;
    this.G = G;
    this.B = B;
    this.vX = vX;
    this.vY = vY;
    this.alpha = alpha;
    //this.size = size;
  }
  
  void plot(PGraphics plot){
    
    //float angle = TWO_PI /  NPol;
    //plot.colorMode(RGB, 255, 255, 255, 255);
    //plot.noStroke();
    plot.fill(this.R*255,this.G*255,this.B*255,this.alpha*255);
    plot.noStroke();
    plot.beginShape();
    //plot.vertex(this.PosX*width/2, this.PosY*height);
    for (int i = 0; i < this.vX.length ; i++){
      //print(this.vX.length + "\n");
      plot.vertex(this.vX[i]*Resolution,this.vY[i]*int(Resolution/ratio));
    }
    plot.endShape(CLOSE); 
  }
  
  void display(PGraphics plot){
    
    //float angle = TWO_PI /  NPol;
    //plot.colorMode(RGB, 255, 255, 255, 255);
    //plot.noStroke();
    plot.fill(this.R*255,this.G*255,this.B*255,this.alpha*255);
    plot.noStroke();
    plot.beginShape();
    //plot.vertex(this.PosX*width/2, this.PosY*height);
    for (int i = 0; i < this.vX.length ; i++){
      //print(this.vX.length + "\n");
      plot.vertex(this.vX[i]*width/2,this.vY[i]*height);
    }
    plot.endShape(CLOSE); 
  }
}
