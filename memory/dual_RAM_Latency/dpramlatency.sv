////////////////////////////////////////////////////////////////////
// 
//      Dual Port RAM with variable Data width and Latency 
//        
//      -------- Parameters declared in the Design -------------
//
//       DATA_WIDTH       =     Width of data output
//       ADDRESS_WIDTH    =     Width of address input
//       READ_LATENCY_A   =     Read latency in clock cycles for port A
//       WRITE_LATENCY_A  =     Write latency in clock cycles for port A
//       READ_LATENCY_B   =     Read latency in clock cycles for port B
//       WRITE_LATENCY_B  =     Write latency in clock cycles for port B 
//
//
//
//      -------- input and output Ports declared in the Design -------------
//
//      clk_a              =     Port - A    input clock
//      en_a               =     Port - A    input enable 
//      we_a               =     Port - A    input write enable 
//      addr_a             =     Port - A    input Address
//      din_a              =     Port - A    input data
//      dout_a             =     Port - A    read output
//
//      clk_b              =     Port - B    input clock	
//      en_b               =     Port - B    input enable 
//      we_b               =     Port - B    input write enable 
//      addr_b             =     Port - B    input Address
//      din_b              =     Port - B    input data
//      dout_b             =     Port - B    read output
//
//
//      -------- wires and registers declared in the Design -------------
//
//      mem                =     Internal memory array
//      shiftreg_wa        =     Write shift register for port A
//      shiftreg_ra        =     Read shift register for port A
//      shiftreg_wb        =     Write shift register for port B
//      shiftreg_rb        =     Read shift register for port B
//      
//
//	
//      
//      NOTE : User cannot write into the same address using dual ports at the 
//             same time step. In this case, the final value stored in the address 
//             location cannot be determined. This case is applicable when both write 
//             latencies of port A and port B are the same.
//
//      Design version : 0.5
// 
////////////////////////////////////////////////////////////////////


module DualPortRamLatency #(
  parameter DATA_WIDTH =8, // Width of data output
  parameter ADDRESS_WIDTH =3, // Width of address input
  parameter READ_LATENCY_A =1, // Read latency in clock cycles for port A
  parameter WRITE_LATENCY_A=1  , // Write latency in clock cycles for port A
  parameter READ_LATENCY_B =1, // Read latency in clock cycles for port B
  parameter WRITE_LATENCY_B =1  // Write latency in clock cycles for port B
) (
  // Port A
  input  logic 					   clk_a,
  input  logic 					   en_a,
  input  logic 					   we_a,  
  input  logic [ADDRESS_WIDTH-1:0] addr_a,
  input  logic [DATA_WIDTH-1:0]    din_a,
  output logic [DATA_WIDTH-1:0]    dout_a,

  // Port B
  input  logic                     clk_b,
  input  logic                     en_b,
  input  logic                     we_b,  
  input  logic [ADDRESS_WIDTH-1:0] addr_b,
  input  logic [DATA_WIDTH-1:0]    din_b,
  output logic [DATA_WIDTH-1:0]    dout_b
);

  // Internal memory array
  logic [DATA_WIDTH-1:0] mem [0:2**ADDRESS_WIDTH-1];

  // Shift registers for write and read data with latencies
  reg [12:0] shiftreg_wa[WRITE_LATENCY_A-1:0]; // Write shift register for port A
  reg [9:0] shiftreg_ra[READ_LATENCY_A-1:0]; // Read shift register for port A
  reg [12:0] shiftreg_wb[WRITE_LATENCY_B-1:0]; // Write shift register for port B
  reg [9:0] shiftreg_rb[READ_LATENCY_B-1:0]; // Read shift register for port B

  reg [2:0] i;

  always @(posedge clk_a)
  begin
    if (en_a && we_a) begin // Write
      shiftreg_wa[0] <= {en_a, we_a, addr_a, din_a}; 
    end else if (en_a && !we_a) begin  //Read
      //shiftreg_wa[0] <= {en_a, we_a, addr_a, din_a}; 
      shiftreg_ra[0] <= {en_a, we_a, mem[addr_a]}; 
    end else begin 
      dout_a <= dout_a; 
    end
  end

  // Process for shifting data with write latency for port A
  always @(posedge clk_a)
  begin
    for (i = 1; i < WRITE_LATENCY_A; i = i + 1) begin 
      shiftreg_wa[i] <= shiftreg_wa[i-1]; 
    end
    
    if (WRITE_LATENCY_A == 1 && en_a && we_a)
        mem[addr_a] <= din_a; 
     else if (shiftreg_wa[WRITE_LATENCY_A-2][12] && shiftreg_wa[WRITE_LATENCY_A-2][11]) begin 
      mem[shiftreg_wa[WRITE_LATENCY_A-2][10:8]] <= shiftreg_wa[WRITE_LATENCY_A-2][7:0]; 
    end
  end

  // Process for shifting data with read latency for port A
  always @(posedge clk_a)
  begin
    for (i = 1; i < READ_LATENCY_A; i = i++) begin 
      shiftreg_ra[i] <= shiftreg_ra[i-1]; 
    end
    if (READ_LATENCY_A == 1 && en_a && ~we_a) 
      dout_a <= mem[addr_a]; 
    else if (shiftreg_ra[READ_LATENCY_A-2][9] && !shiftreg_ra[READ_LATENCY_A-2][8]) begin 
      dout_a <= shiftreg_ra[READ_LATENCY_A-2][7:0]; 
    end
  end

  

  always @(posedge clk_b)
  begin
    if (en_b && we_b) begin 
      shiftreg_wb[0] <= {en_b, we_b, addr_b, din_b}; 
    end else if (en_b && !we_b) begin 
     // shiftreg_wb[0] <= {en_b, we_b, addr_b, din_b}; 
      shiftreg_rb[0] <= {en_b, we_b, mem[addr_b]}; 
    end else begin 
      dout_b <= dout_b; 
    end
  end


// Process for shifting data with write latency for port B
  always @(posedge clk_b)
  begin
    for (i = 1; i < WRITE_LATENCY_B; i = i + 1) begin 
      shiftreg_wb[i] <= shiftreg_wb[i-1]; 
    end
    
    if (WRITE_LATENCY_B == 1 && en_b && we_b) 
      mem[addr_b] <= din_b; 
    else if (shiftreg_wb[WRITE_LATENCY_B-2][12] && shiftreg_wb[WRITE_LATENCY_B-2][11]) begin 
      mem[shiftreg_wb[WRITE_LATENCY_B-2][10:8]] <= shiftreg_wb[WRITE_LATENCY_B-2][7:0]; 
    end
  end

  
// Process for shifting data with read latency for port B
  always @(posedge clk_b)
  begin
    for (i = 1; i < READ_LATENCY_B; i = i + 1) begin 
      shiftreg_rb[i] <= shiftreg_rb[i-1]; 
    end
    if (READ_LATENCY_B == 1 && en_b && ~we_b)       dout_b <= mem[addr_b]; 
    else if (shiftreg_rb[READ_LATENCY_B-2][9] && !shiftreg_rb[READ_LATENCY_B-2][8]) begin 
      dout_b <= shiftreg_rb[READ_LATENCY_B-2][7:0]; 
    end
  end

endmodule
