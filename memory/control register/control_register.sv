module control_register #(
  parameter integer WIDTH = 32  // Width of the register (customizable)
) (
  input logic clk,
  input logic CE,
  input logic [WIDTH-1:0] preset,
  output logic [WIDTH-1:0] q
);

  always_ff @(posedge clk) begin
    if (CE) begin
      q <= preset;
    end
  end

endmodule

