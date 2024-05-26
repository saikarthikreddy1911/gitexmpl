module tb_DualPortRam;

  // Parameters for the DualPortRam module
  parameter integer DATA_WIDTH = 8;
  parameter integer ADDRESS_WIDTH = 3;

  // Inputs and outputs for port A
  logic clk_a, en_a, we_a;
  logic [ADDRESS_WIDTH-1:0] addr_a;
  logic [DATA_WIDTH-1:0] din_a, dout_a;

  // Inputs and outputs for port B
  logic clk_b, en_b, we_b;
  logic [ADDRESS_WIDTH-1:0] addr_b;
  logic [DATA_WIDTH-1:0] din_b, dout_b;

  // Instantiate the DualPortRam module
  DualPortRam #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
  ) dut (    // Port A connections
    .clk_a(clk_a),.en_a(en_a),.we_a(we_a),.addr_a(addr_a),.din_a(din_a),.dout_a(dout_a),

    // Port B connections
    .clk_b(clk_b),.en_b(en_b),.we_b(we_b),.addr_b(addr_b),.din_b(din_b),.dout_b(dout_b)
  );

  // Clock generation
  always #5 clk_a = ~clk_a;
  always #7 clk_b = ~clk_b;

  // Test stimulus generation
  initial begin
    clk_a = 0;
    en_a = 0;
    @(negedge clk_a)  en_a = 1;
    repeat(100) begin
    @(negedge clk_a)  we_a =$urandom_range(0,1) ;
    addr_a = $urandom_range(7);
    din_a = $urandom_range(255);
    fun.sample();
   end
   
   @(negedge clk_a)  we_a = 0;en_a=0;
   @(negedge clk_a) en_a=1;
   fun.sample(); 
end

  initial begin
    clk_b = 0;
    en_b = 0;
    @(negedge clk_b)  en_b = 1;
   repeat(100) begin
    @(negedge clk_b)  we_b =$urandom_range(0,1) ;
    addr_b = $urandom_range(7);
    din_b = $urandom_range(255);
    fun.sample();
   end
   
   @(negedge clk_b)  we_b = 0;en_b=0;
   @(negedge clk_b) en_b=1;
   fun.sample();
   #200 $finish;
  end
   


  // Functional coverage
  covergroup functional_cov;
    option.per_instance = 1;

    coverpoint clk_a;
    coverpoint en_a;
    coverpoint we_a;
    coverpoint addr_a {
      bins addr_a_bin[] = {[0:2**ADDRESS_WIDTH-1]};
    }
    coverpoint din_a{
      bins din_0={0};     
      bins din_mid1={1,127};
      bins din_mid2={128,254};
      bins din_255={255};
}

    coverpoint dout_a{
      bins dout_0={0};     
      bins dout_mid1={1,127};
      bins dout_mid2={128,254};
      bins dout_255={255};
}
    coverpoint clk_b;
    coverpoint en_b;
    coverpoint we_b;
    coverpoint addr_b {
      bins addr_b_bin[] = {[0:2**ADDRESS_WIDTH-1]};
    }
    coverpoint din_b{
      bins din_0={0};     
      bins din_mid1={1,127};
      bins din_mid2={128,254};
      bins din_255={255};
}

    coverpoint dout_b{
      bins dout_0={0};     
      bins dout_mid1={1,127};
      bins dout_mid2={128,254};
      bins dout_255={255};
}
  endgroup
  
   functional_cov fun = new();
  

endmodule

