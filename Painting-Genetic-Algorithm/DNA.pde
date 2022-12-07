class DNA {

  //DNA is array of polygons
  Polygon[] genes;


  DNA() {
    genes = new Polygon[numPol];
    //float red, gre, blu,alph;
    for (int i=0; i<numPol; i++) {
      float vx[] = new float[NPol];
      float vy[] = new float[NPol];
      vx[0] = random(1);
      vy[0] = random(1);
      for (int j = 1; j<NPol; j++) {
        vx[j] = vx[0]+ 0.5*random(1)-0.25;
        vy[j] = vy[0]+ 0.5*random(1)-0.25;
      }
      float red = random(1);
      float gre  = random(1);
      float blu = random(1);
      float aplh = max(random(1)*random(1), 0.2);

      genes[i] = new Polygon(vx, vy, red, gre, blu, aplh);
    }
  }


  DNA(Polygon[] newgenes) {
    genes = newgenes;
  }

  DNA crossover(DNA partner) {
    Polygon[] child = new Polygon[genes.length];
    int crossover = int(random(genes.length));

    for (int i = 0; i < genes.length; i++) {
      if (i > crossover) child[i] = genes[i];
      else               child[i] = partner.genes[i];
    }
    DNA newgenes = new DNA(child);
    return newgenes;
  }




  void mutate(float m) {
    for (int i = 0; i < genes.length; i++) {
      float red, gre, blu, alph;

      if (random(1) < m) {
        //print("check \n");
        red  = constrain(this.genes[i].R + 2*mutateAmount*random(1) - mutateAmount, 0, 1);
      } else {
        //print("no check \n");
        red = this.genes[i].R;
      }
      if (random(1) < m) {
        gre = constrain(this.genes[i].G + 2*mutateAmount*random(1) - mutateAmount, 0, 1);
      } else {
        gre = this.genes[i].G;
      }
      if (random(1) < m) {
        blu = constrain(this.genes[i].B + 2*mutateAmount*random(1) - mutateAmount, 0, 1);
      } else {
        blu = this.genes[i].B;
      }
      if (random(1) < m) {
        alph = constrain(this.genes[i].alpha + 2*mutateAmount*random(1) - mutateAmount, 0, 1);
      } else {
        alph = this.genes[i].alpha;
      }
      float vx[] = new float[NPol];
      float vy[] = new float[NPol];
      for (int j=0; j<NPol; j++) {
        if (random(1) < m) {
          vx[j] = constrain(this.genes[i].vX[j] + 2*mutateAmount*random(1) - mutateAmount, 0, 1);
        } else {
          vx[j] = this.genes[i].vX[j];
        }

        if (random(1) < m) {
          vy[j] = constrain(this.genes[i].vY[j] + 2*mutateAmount*random(1) - mutateAmount, 0, 1);
        } else {
          vy[j] = this.genes[i].vY[j];
        }
      }
      genes[i] = new Polygon(
        vx,
        vy,
        red,
        gre,
        blu,
        alph);
    }
  }
}
