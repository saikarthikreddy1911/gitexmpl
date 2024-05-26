import pkg::*;
class environment;
  
  
  generator  gen_a,gen_b;
  driver     driv_a,driv_b;
  monitor    mon_a,mon_b;
  scoreboard scb_a,scb_b;
  refernce_model ref_a,ref_b; 
  
  mailbox gen2driv_a,gen2driv_b;
  mailbox mon2scb_a,mon2ref_a; 
  mailbox mon2scb_b,mon2ref_b; 
  mailbox ref2scb_a,ref2scb_b;
  
  
  virtual mem_intf mem_vif_a,mem_vif_b;
  

  function new(virtual mem_intf mem_vif_a,virtual mem_intf mem_vif_b);
    this.mem_vif_a = mem_vif_a; 
    this.mem_vif_a = mem_vif_a; 

    gen2driv_a = new();
    gen2driv_b = new();
    mon2scb_a  = new(); 
    mon2scb_b  = new();
    mon2ref_a  = new(); 
    mon2ref_b  = new();
    ref2scb_a  = new();
    ref2scb_b  = new();

    gen_a  = new(gen2driv_a);
    gen_b  = new(gen2driv_b);

    driv_a = new(mem_vif_a,gen2driv_a);
    driv_b = new(mem_vif_b,gen2driv_b);

    mon_a  = new(mem_vif_a,mon2scb_a,mon2ref_a);
    mon_b  = new(mem_vif_b,mon2scb_b,mon2ref_b);

    scb_a   = new(mon2scb_a,ref2scb_a);
    scb_b   = new(mon2scb_b,ref2scb_b);

    ref_a   = new(mon2ref_a,ref2scb_a);
    ref_b   = new(mon2ref_b,ref2scb_b);
  endfunction

  
  task run();
    fork
    gen_a.run();
    gen_b.run();
    driv_a.run();
    driv_b.run();
    mon_a.run();
    mon_b.run();
    ref_a.run();
    ref_b.run();  
    scb_a.run();  
    scb_b.run(); 
    join_any
    
  endtask  
endclass
