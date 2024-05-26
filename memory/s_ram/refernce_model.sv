import pkg::*;
class refernce_model;
   
  mailbox mon2ref,ref2scb;
  static bit [7:0] mem[8];
  transaction ref_trans;
   
  function new(mailbox mon2ref,ref2scb); 
    this.mon2ref = mon2ref;  
    this.ref2scb = ref2scb;
     ref_trans=new();
  endfunction
  

  task run(); 
 
    fork
   
    forever begin
      mon2ref.get(ref_trans);
         //ref_trans.dout=1'b0;
      ref_trans.display("MON-REF GET",ref_trans); 
            
     if(ref_trans.en && !ref_trans.we) begin
        ref_trans.dout = mem[ref_trans.addr];
      end

      else if(ref_trans.en && ref_trans.we) begin
        mem[ref_trans.addr] = ref_trans.din;
     end

      ref2scb.put(ref_trans);
      ref_trans.display("REF-SCB PUT",ref_trans); 
     end
    
    
   join_none
  endtask  
endclass
