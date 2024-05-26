
module SinglePortRAM #
  (
    parameter int DATA_WIDTH = 8,    // Data width
    parameter int ADDR_WIDTH = 3  // Address width    
  )
  (
    input logic clk,                 // Clock input
    input logic [ADDR_WIDTH-1:0] addr,  // Address input
    input logic [DATA_WIDTH-1:0] din,  // Data input
    input logic en,             // Enable Signal
    input logic we,       // Write enable signal
    output logic [DATA_WIDTH-1:0] dout // Data output
  );

  // Internal memory array
  logic [DATA_WIDTH-1:0] mem [0:2**ADDR_WIDTH-1];
  // Temorary register
  logic [DATA_WIDTH-1:0]temp;
  
  // Write operation
   always_ff @(posedge clk) begin
    if (en & we )
      mem[addr] <= din;
  // Read operation
    else if(en & !we)
         dout <= mem[addr];
    end  
    
      

//assign  dout = (en & ~we) ? temp : 'hzz;

endmodule