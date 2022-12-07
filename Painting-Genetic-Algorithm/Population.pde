import java.util.Arrays;
import java.util.Comparator;


class Population{
  
  float mutationRate;
  Individual[] population;
  ArrayList<Individual> matingPool;
  int generations;
  Individual best;
  
  Population(float m, int num){
    mutationRate = m;
    population = new Individual[num];
    matingPool = new ArrayList<Individual>();
    generations = 0;
    
    for (int i=0; i<population.length; i++){
      population[i] = new Individual(new DNA());  
      
    }
  }
  
  void fitness() {
    for (int i = 0; i < population.length; i++) {
      population[i].fitness();
      //print(population[i].fitness+"\n");
    }
  }
  
  void selection() {
    matingPool.clear();
    sortPopulation();

    int cutOff = floor(selectAmount*population.length);
    for (int i = population.length-cutOff; i<population.length; i++) {
      //for (int j = 0; j<i*i; j++) {
      matingPool.add(population[i]);
      //}
      //print(population[i].fitness+ "\n");
    }

    best = population[population.length-1];
  }
  
  void reproduction() {
    int Nchild = floor(1/selectAmount);
    //print(Nchild);
    for (int d = 0; d < matingPool.size(); d++) {
      for(int j=0; j<Nchild;j++){
        int m = d;
        while(m==d){
          m = int(random(matingPool.size()));
        }
        Individual mom = matingPool.get(m);
        Individual dad = matingPool.get(d);
        
        DNA momgenes = mom.getDNA();
        DNA dadgenes = dad.getDNA();
        
        DNA child = momgenes.crossover(dadgenes);
        child.mutate(mutationRate);
        population[d*Nchild + j] = new Individual(child);
        //print(d*Nchild + j + "\n");
      }
    }
    generations++;
  }
  
  

  
  
  void sortPopulation() {
    Arrays.sort(population, Comparator.comparing(Individual::getFitness));
  }
  
}
