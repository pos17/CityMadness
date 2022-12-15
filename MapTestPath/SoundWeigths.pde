class SoundWeights{
  int[] notes;
  float[] weights = {12,4,10,5,11,7,1,8,2,5,2,8};
  
  SoundWeights(int numNodes){
     notes = new int[numNodes];
     for (int i=0; i<numNodes;i++){
      notes[i] = floor(random(12)); 
     }
    normWeights();
    
  }
  
  int getNote(int node){
    
   return notes[node]; 
  }
  
  float getWeigths(int node1, int node2){
    int note1 = notes[node1];
    int note2 = notes[node2];
    int interv = abs(note2 - note1);
    return weights[interv];
  }
  
  void normWeights(){
   int sum = 0;
   for (int i=0; i<weights.length;i++){
    sum+= weights[i]; 
   }
   for (int i=0; i<weights.length;i++){
    weights[i] = weights[i]/sum;
   }
   
  }
  
}
