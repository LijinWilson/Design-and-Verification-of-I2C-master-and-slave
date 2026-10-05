//////////////////// WRITE OPERATION /////////////////////////
// Writing some data into the slave using master

module i2c_master(
  input wire clk, // system clock
  input wire rst_n, // Asychronous active low reset clock
  input wire start, // trigger transaction
  input wire [6:0] addr, // Slave address
  input wire [7:0] data, // data to send
  
  output reg scl, // I2C clock line
  inout reg sda, // I2C bidirectional data line
  output busy // flagging transaction is in progess

);
  
  reg [3:0] state;
  reg [3:0] bit_cnt;
  reg sda_out, sda_oe; // sda_oe flag is used to manage the direction of the bidirectional SDA (Data) line.
  /*
  	- When sda_oe is HIGH (1): The master is actively driving the SDA line to transmit data.
    - When sda_oe is LOW (0): The master essentially disconnects its transmitter from the wire, allowing it to function as an input.
  */
  
  
//   Open-drain SDA
  assign sda = sda_oe ? sda_out : 1'bz;
  
//   State definition, 6 STATES
  localparam IDLE = 0, START = 1, ADDR = 2, ACK1 = 3, DATA = 4, ACK2 = 5, STOP = 6;
  
  always @(posedge clk or negedge rst_n) begin
    
    if(!rst_n) begin
      scl <= 1'b1;
      busy <= 1'b0; // no bus is connected
      bit_cnt <= 1'b0;
      sda_out <= 1'b1;
      sda_oe <= 1'b1; // make master act as sending data, means enablin write operation
      state <= IDLE;
      
    end else begin
      
      case(state)
        
        IDLE: begin // IDLE Case
          scl <= 1'b1;
          sda_out <= 1'b1;
          busy <= 1'b0;
          if(start) begin
            busy <= 1'b1;
            state <= START;
          end
        end
        
        START: begin // START Case
          bit_cnt <= 7; // length of address bit
          sda_out <= 1'b0;
          state <= ADDR;
        end
        
        ADDR: begin // ADDR case. It will loop scl = 0 to bit_cnt = bit_cnt - 1, until bit_cnt become 0, the slave address(addr) will send serially on each iteration
          scl = 1'b0;
          sda_out <= addr[bit_cnt];
          scl <= 1'b1;
          if(bit_cnt == 0) begin
            state <= ACK1;
            sda_out <= 1'b0; // write bit = 0;, making r/w_bar as 0, means enabling write operation.
          end else begin
            bit_cnt = bit_cnt - 1;
          end
        end
        
        ACK1: begin
          scl <= 1'b0;
          sda_oe <= 1'b0; // making the master to take input from slave
          scl <= 1'b1;
          state <= DATA;
          bit_cnt <= 7; // address bit for data bits, data is of 8 bits
          sda_oe <= 1'b0; // now we recieve the acknowledgment from slave, then we are making master back to data sending mode to send(write) the 8 bit data to slave
        end
        
        DATA: begin
          scl <= 1'b0;
          sda_out <= data[bit_cnt];
          scl <= 1'b1;
          if(bit_cnt == 0) begin
            state <= ACK2;
          end else begin
            bit_cnt <= bit_cnt - 1;
          end
        end
        
        ACK2: begin
          scl <= 1'b0;
          sda_oe <= 1'b0; // making the master back to data recieving mode to get the data recieved acknowledgment-ack2 from Slave.
          scl <= 1'b1;
          state <= STOP;
          sda_oe <= 1'b1; // Making master back to data sending mode
        end
        
        STOP: begin
          scl <= 1'b1;
          sda_out <= 1'b0;
          sda_out <= 1'b1; // sending the stop bit, back to high state.
          state <= IDLE;
          busy <= 1'b0; // now other Master and slave can use this I2C bus
        end
      endcase
    end
  end
endmodule
          
          
          
          
          
          
        
        
          
        
        
