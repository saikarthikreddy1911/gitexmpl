module DualPortRam #(
  parameter integer DATA_WIDTH = 8,  // Width of data output
  parameter integer ADDRESS_WIDTH = 3  // Width of address input
) (
  // Port A
  input clk_a,
  input en_a,  
  input  we_a,    // Write enable for port A
  input  [ADDRESS_WIDTH-1:0] addr_a,
  input  [DATA_WIDTH-1:0] din_a,
  output logic [DATA_WIDTH-1:0] dout_a,

  // Port B
  input  clk_b,
  input  en_b,  
  input  we_b,   // Write enable for port B
  input  [ADDRESS_WIDTH-1:0] addr_b,
  input  [DATA_WIDTH-1:0] din_b,
  output logic [DATA_WIDTH-1:0] dout_b
);

  // Internal memory array
  logic [DATA_WIDTH-1:0] mem [0:2**ADDRESS_WIDTH-1];

  // Concurrent port's operations 
  always_ff @(posedge clk_a) begin
    if (en_a && we_a) begin
      mem[addr_a] <= din_a;
    end else if (en_a) begin
      dout_a <= mem[addr_a];
    end
  end

  always_ff @(posedge clk_b) begin
    if (en_b && we_b) begin
      mem[addr_b] <= din_b;
    end else if (en_b) begin
      dout_b <= mem[addr_b];
    end
  end
endmodule

