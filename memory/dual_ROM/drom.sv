
module DualPortRom #(
  parameter integer DATA_WIDTH = 8,  // Width of data output
  parameter integer ADDRESS_WIDTH = 3  // Width of address input (3-bit)
) (
  input logic clk,
  // Port A
  input logic en_a,  // Enable for port A
  input logic [ADDRESS_WIDTH-1:0] addr_a,
  output logic [DATA_WIDTH-1:0] dout_a,

  // Port B
  input logic en_b,  // Enable for port B
  input logic [ADDRESS_WIDTH-1:0] addr_b,
  output logic [DATA_WIDTH-1:0] dout_b
);

  // Internal memory array (ROM)
  logic [DATA_WIDTH-1:0] mem [0:2**ADDRESS_WIDTH-1];

  // Data initialization (modify as needed)
  initial begin
    // Example initialization using case statement
    case (addr_a)
      3'b000: mem[addr_a] = 8'hAA;
      3'b001: mem[addr_a] = 8'h55;
      3'b010: mem[addr_a] = 8'hFF;
      3'b011: mem[addr_a] = 8'hB7;
      3'b100: mem[addr_a] = 8'h56;
      3'b101: mem[addr_a] = 8'h43;
      3'b110: mem[addr_a] = 8'h1F;
      3'b111: mem[addr_a] = 8'hE2;
      default: mem[addr_a] = 8'h00;
    endcase
  end

initial begin
    // Example initialization using case statement
    case (addr_b)
      3'b000: mem[addr_b] = 8'hAA;
      3'b001: mem[addr_b] = 8'h55;
      3'b010: mem[addr_b] = 8'hFF;
      3'b011: mem[addr_b] = 8'hB7;
      3'b100: mem[addr_b] = 8'h56;
      3'b101: mem[addr_b] = 8'h43;
      3'b110: mem[addr_b] = 8'h1F;
      3'b111: mem[addr_b] = 8'hE2;
      default: mem[addr_b] = 8'h00;
    endcase
  end
  // Concurrent read operations
  always_ff @(posedge clk) begin
    if (en_a) begin
      dout_a <= mem[addr_a];
    end
    if (en_b) begin
      dout_b <= mem[addr_b];
    end
  end
endmodule
