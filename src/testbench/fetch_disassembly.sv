module fetch_disassembly(
  IR        ,   // Instruction register output
  FETCH_EN  ,   // Fetch stage enable -> load new instruction
  CLK           // CLk signal
);
  
  input [31:0]IR; 
  input FETCH_EN, CLK;


  function string cond_code_to_string(input logic[3:0] ir_cond_code);
    case (ir_cond_code)
      4'b0000: return "eq";
      4'b0001: return "ne";
      4'b0010: return "cs";
      4'b0011: return "cc";
      4'b0100: return "mi";
      4'b0101: return "pl";
      4'b0110: return "vs";
      4'b0111: return "vc";
      4'b1000: return "hi";
      4'b1001: return "ls";
      4'b1010: return "ge";
      4'b1011: return "lt";
      4'b1100: return "gt";
      4'b1101: return "le";
      4'b1110: return "";
      4'b1111: return "unpredictable_cond_code";
    endcase
  endfunction


  function string reg_to_string(input logic[3:0] ir_reg);
    case (ir_reg)
      4'b0000: return "R0";
      4'b0001: return "R1";
      4'b0010: return "R2";
      4'b0011: return "R3";
      4'b0100: return "R4";
      4'b0101: return "R5";
      4'b0110: return "R6";
      4'b0111: return "R7";
      4'b1000: return "R8";
      4'b1001: return "R9";
      4'b1010: return "R10";
      4'b1011: return "R11";
      4'b1100: return "R12";
      4'b1101: return "R13";
      4'b1110: return "R14";
      4'b1111: return "R15";
    endcase
  endfunction


  function string data_processing_opcode_to_string(input logic[3:0] ir_opcode);
    case (ir_opcode)
      4'b0000: return "AND";
      4'b0001: return "EOX";
      4'b0010: return "SUB";
      4'b0011: return "RSB";
      4'b0100: return "ADD";
      4'b0101: return "ADC";
      4'b0110: return "SBC";
      4'b0111: return "RSC";
      4'b1000: return "TST";
      4'b1001: return "TEQ";
      4'b1010: return "CMP";
      4'b1011: return "CMN";
      4'b1100: return "ORR";
      4'b1101: return "MOV";
      4'b1110: return "BIC";
      4'b1111: return "MVN";
    endcase
  endfunction

  function string shift_type_to_string(input logic[1:0] ir_shift);
    case (ir_shift)
      2'b00:  return "LSL";
      2'b01:  return "LSR";
      2'b10:  return "ASR";
      2'b11:  return "ROR";
    endcase
  endfunction


  always @(posedge CLK)
    begin
      if (FETCH_EN)
        begin
          if (      IR[27:20] == 8'b00010000 &&
                    IR[11:8]  == 4'b000 &&
                    IR[7:4]   == 4'b1001 )
            begin
              $display("SWAP%s %s, %s, %s", cond_code_to_string(IR[31:28]), reg_to_string(IR[15:12]),
                                            reg_to_string(IR[3:0]), reg_to_string(IR[19:16]));
            end
          else if ( IR[27:25] == 4'b001 )
            begin
              int carry,imm, ror_value;
              reg[63:0] temp;
              ror_value = IR[11:8] << 1;
              temp = {24{1'b0}};
              temp = {temp,IR[7:0]};
              temp = {temp[31:0],temp[31:0]};
              temp = temp >> ror_value;
              imm = temp[31:0];
              $display("%s%s%s %s, %s%s %d",
                                data_processing_opcode_to_string(IR[24:21]), 
                                cond_code_to_string(IR[31:28]),
                                IR[20]?"s":"",
                                reg_to_string(IR[15:12]),
                                IR[24:21]!=4'b1101 ? reg_to_string(IR[19:16]) : "",
                                IR[24:21]!=4'b1101 ? "," : "",
                                imm);
            end
          else if(  IR[27:25] == 4'b000 )
            begin
              if (    IR[4] == 1'b0 )
                begin
                  int temp;
                  temp = IR[11:7];
                  $display("%s%s%s %s, %s%s %s %d",
                                    data_processing_opcode_to_string(IR[24:21]), 
                                    cond_code_to_string(IR[31:28]),
                                    IR[20]?"s":"",
                                    reg_to_string(IR[15:12]),
                                    IR[24:21]!=4'b1101 ? reg_to_string(IR[19:16]) : "",
                                    IR[24:21]!=4'b1101 ? "," : "",
                                    reg_to_string(IR[03:00]),
                                    shift_type_to_string(IR[6:5]),
                                    temp);
                end
              else
                begin
                  $display("%s%s%s %s, %s%s %s %s %s",
                                    data_processing_opcode_to_string(IR[24:21]), 
                                    cond_code_to_string(IR[31:28]),
                                    IR[20]?"s":"",
                                    reg_to_string(IR[15:12]),
                                    IR[24:21]!=4'b1101 ? reg_to_string(IR[19:16]) : "",
                                    IR[24:21]!=4'b1101 ? "," : "",
                                    reg_to_string(IR[03:00]),
                                    shift_type_to_string(IR[6:5]),
                                    reg_to_string(IR[11:8]));
                end
            end
          // Load instruction
          else if ( IR[27:25] == 3'b010 &&
                    IR[20]    == 1'b1 )
            begin

              $display("LD%s %s, %s, %s", cond_code_to_string(IR[31:28]), reg_to_string(IR[15:12]),
                                            reg_to_string(IR[3:0]), reg_to_string(IR[19:16]));
            end
          else if ( IR[27:25] == 3'b101 )
            begin
              reg [31:0] temp;
              temp[23:0] = IR[23:0];
              temp[31:24] = {8{IR[23]}};
              $display("B%s%s %d",  cond_code_to_string(IR[31:28]),
                                    IR[24]?"L":"",
                                    $signed(temp));
            end
          else
            begin
              $display("Ciao");
            end
        end
    end





endmodule
