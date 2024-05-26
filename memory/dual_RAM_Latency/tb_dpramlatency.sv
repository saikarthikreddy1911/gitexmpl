module tb_DualPortRamLatency;

  // Parameters for the DualPortRamLatency module
  parameter DATA_WIDTH = 8; // Specifies the width of data in bits
  parameter ADDRESS_WIDTH = 3; // Specifies the width of address in bits
  parameter READ_LATENCY_A = 1;  // Read latency in clock cycles for port A
  parameter WRITE_LATENCY_A = 2; // Write latency in clock cycles for port A
  parameter READ_LATENCY_B = 2;  // Read latency in clock cycles for port B
  parameter WRITE_LATENCY_B = 1;  // Write latency in clock cycles for port B

  // Inputs and outputs for port A
  logic clk_a, en_a, we_a; 
  logic [ADDRESS_WIDTH-1:0] addr_a; 
  logic [DATA_WIDTH-1:0] din_a, dout_a; 

  // Inputs and outputs for port B
  logic clk_b, en_b, we_b; 
  logic [ADDRESS_WIDTH-1:0] addr_b; 
  logic [DATA_WIDTH-1:0] din_b, dout_b; 

  logic [DATA_WIDTH-1:0] ref_mem [0:2**ADDRESS_WIDTH-1];
  logic [DATA_WIDTH-1:0] dout_ref_a, dout_ref_b;

  // Instantiate the DualPortRamLatency module
  DualPortRamLatency #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .READ_LATENCY_A(READ_LATENCY_A),
    .WRITE_LATENCY_A(WRITE_LATENCY_A),
    .READ_LATENCY_B(READ_LATENCY_B),
    .WRITE_LATENCY_B(WRITE_LATENCY_B)
  ) dut (
    // Port A connections
    .clk_a(clk_a), .en_a(en_a), .we_a(we_a), .addr_a(addr_a), .din_a(din_a), .dout_a(dout_a),

    // Port B connections
    .clk_b(clk_b), .en_b(en_b), .we_b(we_b), .addr_b(addr_b), .din_b(din_b), .dout_b(dout_b)
  );

  // Clock generation for port A and port B
  always #5 clk_a = ~clk_a; 
  always #7 clk_b = ~clk_b; 

  
  initial begin
    clk_a = 0; 
    en_a = 0; 
    we_a = 0; 
    @(negedge clk_a) en_a = 1; 
  repeat(100) begin 
      @(negedge clk_a) randomize(we_a,din_a,addr_a) with {if(we_a && we_b) addr_a!=addr_b;};
      fun.sample(); 
    end
    @(negedge clk_a) we_a = 1; en_a = 0; 
    @(negedge clk_a) en_a = 1;we_a=0; 
    @(negedge clk_a) en_a = 1;we_a=1; 
    fun.sample(); 
  end

  initial begin
    clk_b = 0; 
    en_b = 0; 
    we_b = 0; 
    @(negedge clk_b) en_b = 1; 
    repeat(100) begin 
      @(negedge clk_b) randomize(we_b,din_b,addr_b) with {if(we_a && we_b) addr_a!=addr_b;};
      fun.sample(); 
    end
    @(negedge clk_b) we_b = 1;en_b= 0; 
    @(negedge clk_b) en_b = 1;we_b=0; 
    @(negedge clk_b) en_b = 1;we_b=1; 
    fun.sample(); 
    #200 $finish; 
  end

  // Functional coverage definition
  covergroup functional_cov;
    option.per_instance = 1;     
    coverpoint clk_a; 
    coverpoint en_a; 
    coverpoint we_a; 
    coverpoint addr_a { 
      bins addr_a_bin[] = {[0:2**ADDRESS_WIDTH-1]}; 
    }
    coverpoint din_a { 
      bins din_0 = {0}; 
      bins din_mid1 = {1, 127}; 
      bins din_mid2 = {128, 254}; 
      bins din_255 = {255}; 
    }
    coverpoint dout_a { 
      bins dout_0 = {0}; 
      bins dout_mid1 = {1, 127}; 
      bins dout_mid2 = {128, 254}; 
      bins dout_255 = {255}; 
    }
  
    coverpoint clk_b; 
    coverpoint en_b; 
    coverpoint we_b; 
    coverpoint addr_b { 
      bins addr_b_bin[] = {[0:2**ADDRESS_WIDTH-1]}; 
    }
    coverpoint din_b { 
      bins din_0 = {0}; 
      bins din_mid1 = {1, 127}; 
      bins din_mid2 = {128, 254}; 
      bins din_255 = {255}; 
    }
    coverpoint dout_b { 
      bins dout_0 = {0}; 
      bins dout_mid1 = {1, 127}; 
      bins dout_mid2 = {128, 254}; 
      bins dout_255 = {255}; 
    }  

  endgroup 
 
  functional_cov fun = new(); // Create an instance of the functional coverage group

//Refernce module for Memory behavior simulation
always @(posedge clk_a) begin
       if(en_a && we_a)begin
            ref_mem[addr_a] <= repeat (WRITE_LATENCY_A-1) @(posedge clk_a) din_a;
       end
       else if(en_a && ~we_a)
            dout_ref_a     <= repeat (READ_LATENCY_A-1) @(posedge clk_a) ref_mem[addr_a];
       else 
            dout_ref_a<=dout_ref_a;
end
 
always @(posedge clk_b) begin
       if(en_b && we_b)begin
            ref_mem[addr_b] <= repeat (WRITE_LATENCY_B-1) @(posedge clk_b) din_b;
       end
       else if(en_b && ~we_b)
            dout_ref_b     <= repeat (READ_LATENCY_B-1) @(posedge clk_b) ref_mem[addr_b];
       else
            dout_ref_b<=dout_ref_b;
end
 
  // Output data comparison
always @(posedge clk_a) begin
       if(dout_ref_a) begin
           if(dout_ref_a==dout_a)
              $display("Output Data matched for Port A");
           else
              $display("Output Data not matched for Port A",$time);
       end
end
 
always @(posedge clk_b) begin
       if(dout_ref_b) begin
           if(dout_ref_b==dout_b)
              $display("Output Data matched for Port B");
           else
              $display("Output Data not matched for Port B",$time);
       end
end
endmodule 

