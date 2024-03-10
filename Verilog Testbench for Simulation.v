// This testbench will exercise the UART RX and PWM Genrator
// It sends out byte 0x37, and ensures the RX receives it correctly.
`timescale 1ns/10ps

module UART_RX_PWM_TB();

  // Testbench uses a 25 MHz clock (same as Go Board)
  // Want to interface to 115200 baud UART
  // 25000000 / 115200 = 217 Clocks Per Bit.
  parameter c_CLOCK_PERIOD_NS = 40;
  parameter c_CLKS_PER_BIT    = 217;
  parameter c_BIT_PERIOD      = 8600;
  
  reg r_Clock = 0;
  reg r_RX_Serial = 1;
  wire [7:0] w_RX_Byte;
  wire o_pwm;
  

  // Takes in input byte and serializes it 
  task UART_WRITE_BYTE;
    input [7:0] i_Data;
    integer     j;
    begin
      
      // Send Start Bit
      r_RX_Serial <= 1'b0;
      #(c_BIT_PERIOD);
      #1000;
      
      // Send Data Byte
      for (j=0; j<8; j=j+1) 
        begin
          r_RX_Serial <= i_Data[j];
          #(c_BIT_PERIOD);
        end
      
      // Send Stop Bit
      r_RX_Serial <= 1'b1;
      #(c_BIT_PERIOD);
     end
  endtask // UART_WRITE_BYTE
  
  
  UART_RX_PWM #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_INST
    (.i_Clock(r_Clock),
     .i_RX_SerialBus(r_RX_Serial),
     .o_RX_DV(),
     .o_RX_Data(w_RX_Byte),
     .o_pwm(o_pwm)
     );
  
  always
    #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;

  
  // Main Testing:
  initial
    begin
      // Send a command to the UART (exercise Rx)
      @(posedge r_Clock);
      UART_WRITE_BYTE(8'd77);
      @(posedge r_Clock);
            
      // Check that the correct command was received
      if (w_RX_Byte == 8'd77)
        $display("Test Passed - Correct Byte Received");
      else
        $display("Test Failed - Incorrect Byte Received");
    $finish();
    end
  
  initial 
  begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
endmodule
