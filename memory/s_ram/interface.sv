interface mem_intf(input  clk);
  
  //declaring the signals
  logic [2:0] addr;
  logic en;
  logic we;
  logic [7:0] din;
  logic [7:0] dout;
  
  //driver clocking block
  clocking driver_cb @(negedge clk);   
    output addr;
    output en;
    output we;
    output din;
    input  dout;  
  endclocking
  
  //monitor clocking block
  clocking monitor_cb @(posedge clk);   
    input addr;
    input we;
    input en;
    input din;
    input dout;  
  endclocking

  
endinterface
