import pkg::*;
class scoreboard;
   
  mailbox mon2scb,ref2scb;
  

  function new(mailbox mon2scb,mailbox ref2scb); 
    this.mon2scb = mon2scb;  
    this.ref2scb = ref2scb;
  endfunction
  

  task run();  
    transaction trans;
    transaction ref_trans;
    ref_trans=new();
    trans=new();
    forever begin
      mon2scb.get(trans);
      trans.display("MON-SCB GET",trans); 
      
      ref2scb.get(ref_trans);
      ref_trans.display("MNO-REF GET",trans); 
    
   if(ref_trans.dout == trans.dout)
         $display("data matched dout = %d,ref_dout =%d",trans.dout,ref_trans.dout);
     else 
         $display("data not mactehd dout = %d,ref_dout =%d",trans.dout,ref_trans.dout);

    end
    
  endtask  
endclass
