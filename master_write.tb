module master_write_tb();
  reg clk, rst_n, start;
  reg [6:0] addr;
  reg [7:0] data;
  wire sda;
  wire scl;
  wire busy;
  
//   Making the sda line permanently pulled up to high;
  pullup(sda);
  
//   Instantiating the design module
  i2c_master tt1(clk, rst_n, start, addr, data, scl, sda, busy);
  
  
//   Clock Generation
  initial
    begin
      
      clk = 1'b0;
      
      forever #5 clk = ~clk; // 100MHz
    end
  
//   Data loading and reset
  initial   
    begin
      rst_n = 0; start = 0; addr = 7'b0110110; data = 8'b11000011;
      
      #20; rst_n = 1;
      
      #30; start = 1; // Triggering Transaction
      
      #10; start = 0;
      
      #500; $finish();
      
    end

//   Waveform file
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars(0, master_write_tb);
    end

  
  
