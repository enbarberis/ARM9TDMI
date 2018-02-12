`timescale 1 ns / 1 ps


module fetch_disassembly_tb();
 
  integer i;
  reg FETCH_EN_s, CLK_s;
  reg [31:0] IR_s;
  reg [31:0] memry[1023:0];

  always 
    begin
      #5 CLK_s = !CLK_s;
    end

  


  initial
    begin
      $readmemh("./input_tb.hex", memry, 0);
      CLK_s = 0;
      @(posedge CLK_s)
      #1
      FETCH_EN_s <= 1'b1;
      for (i = 0 ; i < 1024; i = i+1 )
        begin
          IR_s <= memry[i];
          @(posedge CLK_s);
        end
    end

  fetch_disassembly dut (
    .IR(IR_s),
    .FETCH_EN(FETCH_EN_s),
    .CLK(CLK_s)
  );


endmodule



