import pkg::*;
class generator;
  
  transaction trans;
  int  repeat_count;
   mailbox gen2driv;
  
    
  //constructor
  function new(mailbox gen2driv);
    this.gen2driv = gen2driv;
  endfunction
  

  task run();
    fork
      trans = new();
    repeat(50) begin
     // trans = new();
     wait(gen2driv.num()==0)
      trans.randomize() with {trans.en==1;};
      //trans.display("GENERATOR random",trans); 
      gen2driv.put(trans);
      //trans.display("Gen trans=%p");
     trans.display("GENERATOR mailbox put",trans); 
      
    end
   join_none
  endtask
endclass
