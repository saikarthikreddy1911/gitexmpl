//`include "environment.sv"
import pkg::*;
class test;
      environment env;
      virtual mem_intf mem_vif_a,mem_vif_b;
      function new(virtual mem_intf mem_vif_a, virtual mem_intf mem_vif_b);
	this.mem_vif_a =mem_vif_a;
	this.mem_vif_b =mem_vif_b;
      endfunction
      task run;
	env =new(mem_vif_a,mem_vif_b);
	env.run;
      endtask
endclass
