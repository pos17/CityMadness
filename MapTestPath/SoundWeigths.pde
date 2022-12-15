class SoundWeights{
  HashMap<Integer,Integer> notes; //= new HashMap<Integer,String>();
  
  //int[] notes;
  float[] weights = {12,4,10,5,11,7,1,8,2,5,2,8};
  
  SoundWeights(){
    notes = new HashMap<Integer, Integer>();
    normWeights();
  }
  
  void addNote(int noteId) {
    int NoteVal = int(random(0,11));
    notes.put(noteId,NoteVal);
  }
  
  
  int getNoteVal(int node){
    
   return notes.get(node); 
  }
  
  float getWeights(int node1, int node2){
    //println(notes); //<>//
    //println("couple");
    //println(node1);
    //println(node2);
    int note1 = notes.get(node1);
    int note2 = notes.get(node2);
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
  
  IntList generateMidiList(IntList ids) {
    IntList midi = new IntList();
    for(int i =0; i< ids.size();i++) {
      midi.append(notes.get(ids.get(i)));
    }
    
    println(midi);
    return midi;
  }
  
}
