module DualPortRamLatency_ECC #(parameter READ_LATENCY_A = 3, // Read latency in clock cycles for port A
                                WRITE_LATENCY_A = 2 , // Write latency in clock cycles for port A
                                READ_LATENCY_B = 3, // Read latency in clock cycles for port B
                                WRITE_LATENCY_B = 2, // Write latency in clock cycles for port B
                                DATA_WIDTH = 8,
                                ADDRESS_WIDTH = 3,
                                ERROR_EN_A=2,
                                ERROR_EN_B=2
                               
                               ) (
  // Port A
  input logic clk_a,
  input logic en_a,
  input logic we_a,  
  input logic [ADDRESS_WIDTH-1:0] addr_a,
  input logic [DATA_WIDTH-1:0] din_a,
  output logic [DATA_WIDTH-1:0] dout_a,  
  
  // Port B
  input logic clk_b,
  input logic en_b,
  input logic we_b,  
  input logic [ADDRESS_WIDTH-1:0] addr_b,
  input logic [DATA_WIDTH-1:0] din_b,
  output logic [DATA_WIDTH-1:0] dout_b  
);
  
  
  parameter PARITY_SIZE=5;
  reg [DATA_WIDTH+PARITY_SIZE:1] mem [0:2**ADDRESS_WIDTH-1];
  
  reg [PARITY_SIZE:1]p;
  reg [PARITY_SIZE-2:0]c;
  reg P;  
  reg [2:0] i; 
  
  reg        [13:1]        hamm_en_a;            //Hamming encoder output PORT A
  reg        [13:1]        hamm_en_b;            //Hamming encoder output PORT B
  
  reg        [13:1]        error_in_A;           //1 Bit error injection PORT A
  reg        [13:1]        error_in_B;           //1 Bit Error injrction PORT B
  
  reg        [3:0]         error_injected_addr;  //injected error address
  reg        [3:0]         error_det_addr_a;     //Detected error address PORT A 
  reg        [3:0]         error_det_addr_b;     //Detected error address PORT B
  
  reg        [1:0]         error_injection_a;    //To decide error injection is 0/1/2 PORT A
  reg        [1:0]         error_injection_b;    //To decide error injection is 0/1/2 PORT B
  
  reg                      p_dec_a;              //Parity of hamming decoder output PORT A 
  reg                      p_dec_b;              //Parity of hamming decoder output PORT B
  
  reg       [13:1]         err_in_2;

 // Shift registers for write and read data with latencies
  reg [17:0] shiftreg_wa[WRITE_LATENCY_A-1:0]; 
  reg [9:0] shiftreg_ra[READ_LATENCY_A-1:0]; 
  reg [17:0] shiftreg_wb[WRITE_LATENCY_B-1:0]; 
  reg [9:0] shiftreg_rb[READ_LATENCY_B-1:0]; 

  task  hamming_encoder(input [7:0]din,output [13:1]din_prt,output [1:0] error_injection); begin  
    p[1] = din[0] ^ din[1] ^ din[3] ^ din[4] ^ din[6]; 
    p[2] = din[0] ^ din[2] ^ din[3] ^ din[5] ^ din[6]; 
    p[3] = din[1] ^ din[2] ^ din[3] ^ din[7];  
    p[4] = din[4] ^ din[5] ^ din[6] ^ din[7]; 
    p[5] = din[7] ^ din[6] ^ din[5] ^ din[4] ^ p[3] ^ din[3] ^ din[2] ^ din[1] ^ p[2] ^ din[0] ^ p[1] ^ p[0];    
    din_prt={p[5] , din[7] , din[6] , din[5] , din[4] , p[4] , din[3] , din[2] , din[1] , p[3] , din[0] , p[2] , p[1]}; 
    error_injection=$urandom_range(2);
  end 
  endtask

//  task  hamming_decoder(input [13:1]din,input[2:0]addr); begin    
//    P = din[13] ^ din[12] ^ din[11] ^ din[10] ^ din[9] ^ din[8] ^ din[7] ^ din[6] ^ din[5] ^ din[4] ^ din[3] ^ din[2] ^ din[1];     
//    c[0] = din[1] ^ din[3] ^ din[5] ^ din[7] ^ din[9] ^ din[11];    
//    c[1] = din[2] ^ din[3] ^ din[6] ^ din[7] ^ din[10] ^ din[11];    
//    c[2] = din[4] ^ din[5] ^ din[6] ^ din[7] ^ din[12];    
//    c[3] = din[8] ^ din[9] ^ din[10] ^ din[11] ^ din[12];   
//    
//    if(~c && ~P) begin
//      $display("No Error");
//      mem[addr]=mem[addr];
//     end else if(~c && P) begin
//      $display("Detected error  in last parity bit ",$time);
//      mem[addr][13] = ~mem[addr][13];
//      $display("Corrected error  in last parity bit ");
//    end else if(c && ~P) begin
//      $display("Double bit error detected can't be correct",$time);
//      mem[addr] = mem[addr]; 
//    end else begin
//      $display("Single bit error detected at %d",c);
//      mem[addr][c-1] = ~mem[addr][c-1];
//      $display("Single bit error corrected");
//    end
//    //dout_prt={din[12] , din[11] , din[10] , din[9] , din[7] , din[6] , din[5] , din[3]};
//  end
//  endtask

  task  hamming_decoder(input  [13:1]din,output [3:0]c,output P);begin    
    P = din[13] ^ din[12] ^ din[11] ^ din[10] ^ din[9] ^ din[8] ^ din[7] ^ din[6] ^ din[5] ^ din[4] ^ din[3] ^ din[2] ^ din[1];     
    c[0] = din[1] ^ din[3] ^ din[5] ^ din[7] ^ din[9] ^ din[11];    
    c[1] = din[2] ^ din[3] ^ din[6] ^ din[7] ^ din[10] ^ din[11];    
    c[2] = din[4] ^ din[5] ^ din[6] ^ din[7] ^ din[12];    
    c[3] = din[8] ^ din[9] ^ din[10] ^ din[11] ^ din[12]; 
     end
  endtask  
  
  //WHY
  task error_injection(input [13:1]din,output[13:1]err_din);
    begin
      error_injected_addr = $urandom_range(1,13);
      din[error_injected_addr]=~din[error_injected_addr];
      err_din=din; 
    end
  endtask
  
  //WHY
  task error_injection2(input [13:1]din,output[13:1]err_din2);
    begin
      error_injected_addr = $urandom_range(1,12);
      din[error_injected_addr]=~din[error_injected_addr];
      din[error_injected_addr+1]=~din[error_injected_addr+1];
      err_din2=din;
    end
  endtask
  
  
  task error_det_corr(input P,input [3:0]c,input [2:0] addr); begin
    if(!c && !P) 
      mem[addr]=mem[addr];
    else if(c && P) 
      mem[addr] [c] = ~mem[addr] [c];
    else if(c && !P) begin
      //$error , $fatal
      $display($time,"Dual error detected cannot be corrected");
      mem[addr]=mem[addr];  
    end    
    else if(!c && P) 
      mem[addr][13]=~mem[addr][13];
    else 
      mem[addr]=mem[addr];
  end

endtask
 

    
// Process for port A write and read with latencies
  always @(posedge clk_a)  begin
    if (en_a && we_a) begin
      hamming_encoder(din_a,hamm_en_a,error_injection_a);
      if(ERROR_EN_A) begin
        case (error_injection_a) 
          /* 2'b00  : begin
          if(WRITE_LATENCY_A==1)  mem[addr_a] <= hamm_en_a;
          else
          shiftreg_wa[0] <= {en_a,we_a,addr_a,hamm_en_a};
          end */
          2'b01  : begin
            error_injection(hamm_en_a,error_in_A);
            if(WRITE_LATENCY_A==1)  
              mem[addr_a] <= error_in_A;
            else 
              shiftreg_wa[0]<={en_a,we_a,addr_a,error_in_A};
          end
          2'b10  : begin
            error_injection2(hamm_en_a,err_in_2);
            if(WRITE_LATENCY_A==1) 
              mem[addr_a] <= err_in_2;
            else               
              shiftreg_wa[0]<={en_a,we_a,addr_a,err_in_2};
          end
          default :  begin
            if(WRITE_LATENCY_A==1)  
              mem[addr_a] <= hamm_en_a;
            else    
              shiftreg_wa[0] <= {en_a,we_a,addr_a,hamm_en_a};
          end
        endcase
      end else begin
        if(WRITE_LATENCY_A==1)  mem[addr_a] <= hamm_en_a;
        else  shiftreg_wa[0] <= {en_a,we_a,addr_a,hamm_en_a};
      end
    
    end else if (en_a && ~we_a) begin 
      hamming_decoder(mem[addr_a],error_det_addr_a,p_dec_a);
      error_det_corr(p_dec_a,error_det_addr_a,addr_a);      
      if (READ_LATENCY_A == 1)begin
        dout_a <= {mem[addr_a][11],mem[addr_a][10],mem[addr_a][9],mem[addr_a][7],mem[addr_a][6],mem[addr_a][5],mem[addr_a][3]};
      end else  begin
        shiftreg_wa[0] <= {0, we_a, addr_a,hamm_en_a}; 
        shiftreg_ra[0] <= {en_a, we_a, mem[addr_a][11],mem[addr_a][10],mem[addr_a][9],mem[addr_a][7],mem[addr_a][6],mem[addr_a][5],mem[addr_a][3]};  
      end end else begin 
        dout_a <= dout_a;
      end
  end


  // Process for shifting data with write latency for port A
  always @(posedge clk_a)    begin
      for (i = 1; i < WRITE_LATENCY_A; i = i + 1) begin 
        shiftreg_wa[i] <= shiftreg_wa[i-1]; 
      end
      
      if (shiftreg_wa[WRITE_LATENCY_A-2][17] && shiftreg_wa[WRITE_LATENCY_A-2][16]) begin 
        mem[shiftreg_wa[WRITE_LATENCY_A-2][15:13]] <= shiftreg_wa[WRITE_LATENCY_A-2][12:0]; 
      end
    end

  // Process for shifting data with read latency for port A
  always @(posedge clk_a)  begin
    for (i = 1; i < READ_LATENCY_A; i = i++) begin 
      shiftreg_ra[i] <= shiftreg_ra[i-1]; 
    end
    if (shiftreg_ra[READ_LATENCY_A-2][9] && !shiftreg_ra[READ_LATENCY_A-2][8]) begin 
      dout_a <= shiftreg_ra[READ_LATENCY_A-2][7:0]; 
    end
  end
  





// Process for port B write and read with latencies
  
  always @(posedge clk_b)  begin
    if (en_b && we_b) begin
      hamming_encoder(din_b,hamm_en_b,error_injection_b);
      if(ERROR_EN_B) begin
        case (error_injection_b) 
          /* 2'b00  : begin
          if(WRITE_LATENCY_B==1)  mem[addr_b] <= hamm_en_b;
          else                shiftreg_wb[0] <= {en_b,we_b,addr_b,hamm_en_b};
          end */
          2'b01  : begin
            error_injection(hamm_en_b,error_in_B);
            if(WRITE_LATENCY_B==1)  
              mem[addr_b] <= error_in_B;
            else 
              shiftreg_wb[0]<={en_b,we_b,addr_b,error_in_B};
          end
          2'b10  : begin
            error_injection2(hamm_en_b,err_in_2); 
            if(WRITE_LATENCY_B==1) 
              mem[addr_b] <= err_in_2;
            else   
              shiftreg_wb[0]<={en_b,we_b,addr_b,err_in_2};
          end
          default :  begin
            if(WRITE_LATENCY_B==1)  
              mem[addr_b] <= hamm_en_b;
            else 
              shiftreg_wb[0] <= {en_b,we_b,addr_b,hamm_en_b};
          end
        endcase
      
      end else begin
        if(WRITE_LATENCY_B==1)  
          mem[addr_b] <= hamm_en_b;
        else  
          shiftreg_wb[0] <= {en_b,we_b,addr_b,hamm_en_b}; 
      end
    
    end else if (en_b && ~we_b) begin
      hamming_decoder(mem[addr_b],error_det_addr_b,p_dec_b);
      error_det_corr(p_dec_b,error_det_addr_b,addr_b);
      if (READ_LATENCY_A == 1 && en_a && ~we_a) begin
        dout_a <= {mem[addr_b][11],mem[addr_b][10],mem[addr_b][9],mem[addr_b][7],mem[addr_b][6],mem[addr_b][5],mem[addr_b][3]}; 
      end else begin
        dout_a <= shiftreg_ra[READ_LATENCY_A-2][7:0];
        shiftreg_wb[0] <= {0, we_b, addr_b,hamm_en_b};
        shiftreg_rb[0] <= {en_b, we_b, mem[addr_b][11],mem[addr_b][10],mem[addr_b][9],mem[addr_b][7],mem[addr_b][6],mem[addr_b][5],mem[addr_b][3]};
      end 
    
    end else begin 
      dout_b <= dout_b; 
    end
  end

  // Process for shifting data with write latency for port B
  always @(posedge clk_b)  begin
    for (i = 1; i < WRITE_LATENCY_B; i = i + 1) begin 
      shiftreg_wb[i] <= shiftreg_wb[i-1]; 
    end
    
    if (shiftreg_wb[WRITE_LATENCY_B-2][17] && shiftreg_wb[WRITE_LATENCY_B-2][16]) begin 
      mem[shiftreg_wb[WRITE_LATENCY_B-2][15:13]] <= shiftreg_wb[WRITE_LATENCY_B-2][12:0];
    end
  end

  // Process for shifting data with read latency for port B
  always @(posedge clk_b)  begin
    for (i = 1; i < READ_LATENCY_B; i = i + 1) begin 
      shiftreg_rb[i] <= shiftreg_rb[i-1]; 
    end
    if (shiftreg_rb[READ_LATENCY_B-2][9] && !shiftreg_rb[READ_LATENCY_B-2][8]) begin
      dout_b <= shiftreg_rb[READ_LATENCY_B-2][7:0];     
    end
  end
endmodule