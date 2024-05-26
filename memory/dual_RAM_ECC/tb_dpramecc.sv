module tb_DualPortRamLatency_ECC;
  // Parameters
  parameter READ_LATENCY_A  = 3,
            WRITE_LATENCY_A = 2, 
            READ_LATENCY_B  = 3, 
            WRITE_LATENCY_B = 2,
            DATA_WIDTH      = 8, 
            ADDRESS_WIDTH   = 3, 
            ERROR_EN_A        = 2,
            ERROR_EN_B        = 2;

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
  DualPortRamLatency_ECC #(
    .READ_LATENCY_A(READ_LATENCY_A),
    .WRITE_LATENCY_A(WRITE_LATENCY_A),
    .READ_LATENCY_B(READ_LATENCY_B),
    .WRITE_LATENCY_B(WRITE_LATENCY_B),
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .ERROR_EN_A(ERROR_EN_A),
    .ERROR_EN_B(ERROR_EN_B)
  ) dut (
    // Port A connections
    .clk_a(clk_a), .en_a(en_a), .we_a(we_a), .addr_a(addr_a), .din_a(din_a), .dout_a(dout_a),

    // Port B connections
    .clk_b(clk_b), .en_b(en_b), .we_b(we_b), .addr_b(addr_b), .din_b(din_b), .dout_b(dout_b)
  );


  // Clock generation
  always begin
    #5 clk_a = !clk_a;
    #5 clk_b = !clk_b;
  end

task read_write_A;
  begin
  @(negedge clk_a) 
  en_a=$urandom;
   randomize(we_a,din_a,addr_a) with {if(we_a && we_b) addr_a!=addr_b;};
   if(we_a) begin
    write.sample(); 
   end
   else  read.sample();
 end
endtask

task read_write_B;
 begin
   @(negedge clk_b)
    en_b=$urandom;
   randomize(we_b,din_b,addr_b) with {if(we_a && we_b) addr_b!=addr_a;};
   if(we_b) begin
    write.sample(); 
   end
   else  read.sample();
 end
endtask




  initial begin
 clk_a=0;clk_b=0;en_a=0;en_b=0;
 we_a=0;we_b=0;



  repeat(100) begin
    read_write_A;
    read_write_B;
    if(write.get_coverage()==100 && read.get_coverage()==100) break;
  end
 
 write.get_coverage(); 
 #1000  $finish;
end 

//Functional coverage
//Write coverage 
covergroup write_coverage;
          ADDR_A: coverpoint addr_a{
                       bins zero ={[0:1]};
                       bins mid  ={[2:5]};
                       bins last ={[6:7]};}
          ADDR_B : coverpoint addr_b{
                      bins zero ={[0:1]};
                      bins mid  ={[2:5]};
                      bins last ={[6:7]};}
          DIN_A: coverpoint din_a{
                       bins zero ={0};
                       bins mid  ={[1:200]};
                       bins last ={[201:255]};}
          DIN_B: coverpoint din_b{
                       bins zero ={0};
                       bins mid  ={[1:200]};
                       bins last ={[201:255]};}
          WRITE : coverpoint we_a{  
                       bins b1={1};}
          
endgroup:write_coverage

//Read coverage 
covergroup read_coverage;
          ADDR_A: coverpoint addr_a{
                       bins zero ={[0:1]};
                       bins mid  ={[2:5]};
                       bins last ={[6:7]};}
          ADDR_B : coverpoint addr_b{
                      bins zero ={[0:1]};
                      bins mid  ={[2:5]};
                      bins last ={[6:7]};}
          DIN_A: coverpoint din_a{
                       bins zero ={0};
                       bins mid  ={[1:200]};
                       bins last ={[201:255]};}
          DIN_B: coverpoint din_b{
                       bins zero ={0};
                       bins mid  ={[1:200]};
                       bins last ={[201:255]};}
          READ : coverpoint we_a{  
                       bins b1 ={0};}
          
endgroup:read_coverage

//Handles for functional coverages
write_coverage  write = new();
read_coverage   read  = new();



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