module SinglePortROM #(
  parameter  DATA_WIDTH = 8,  // Width of data output
  parameter  ADDRESS_WIDTH = 3  // Width of address input (3-bit)
) (
  input logic clk,
  input logic en,                  // Optional enable input
  input logic [ADDRESS_WIDTH-1:0] addr,
  output logic [DATA_WIDTH-1:0] dout
);

  // Internal memory array
  logic [DATA_WIDTH-1:0] mem [0:2**ADDRESS_WIDTH-1];

  // Data initialization
  initial begin
    // Initialization using case statement
    case (addr)
      3'b000: mem[addr] = 8'hAA;
      3'b001: mem[addr] = 8'h55;
      3'b010: mem[addr] = 8'hFF;
      3'b011: mem[addr] = 8'hB7;
      3'b100: mem[addr] = 8'h56;
      3'b101: mem[addr] = 8'h43;
      3'b110: mem[addr] = 8'h1F;
      3'b111: mem[addr] = 8'hE2;
      default: mem[addr] = 8'h00;
    endcase
  end

  // Read operation
  always_ff @(posedge clk) begin
    if (en) begin
      dout <= mem[addr];
    end else begin
      // Set output to a specific value when disabled
      dout <= 8'hzz;  // High-Z for tri-state outputs
    end
  end
endmodule


