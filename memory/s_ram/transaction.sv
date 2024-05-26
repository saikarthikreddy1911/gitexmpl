import pkg::*;
class transaction;

  randc logic [2:0] addr;
  rand logic       we;
  rand logic       en;
  randc logic [7:0] din;
       logic [7:0] dout;
      

   function void display(input string name,input transaction trans);
     $display("----------------------[%s]-----------------------",name);
     $display($time,"-------------address=%0d,we=%0d,en=%0d,din=%0d,dout=%0d--------------\n",addr,we,en,din,dout);
   endfunction

 
  
endclass
