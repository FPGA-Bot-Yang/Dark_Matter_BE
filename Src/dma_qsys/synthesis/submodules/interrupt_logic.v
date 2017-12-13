module interrupt_logic (
  clk,
  reset,
  data_in,
  write,
  write_data,
  address_decode,
  irq_mask_reg_en,
  edge_capture_reg_en,
  read_data,
  irq_out
);

parameter DATA_WIDTH = 32;

input clk;
input reset;
input [DATA_WIDTH-1:0] data_in;
input write;
input [DATA_WIDTH-1:0] write_data;
input address_decode;
input irq_mask_reg_en;
input edge_capture_reg_en;
output reg [DATA_WIDTH-1:0] read_data;
output wire irq_out;

//internal logic
reg [DATA_WIDTH-1:0] data_in_d1;
reg [DATA_WIDTH-1:0] data_in_d2;
reg [DATA_WIDTH-1:0] data_in_d3;
wire [DATA_WIDTH-1:0] edge_detect;
reg [DATA_WIDTH-1:0] edge_capture;
reg [DATA_WIDTH-1:0] irq_mask;
wire edge_capture_wr_strobe;
wire irq_mask_wr_strobe;
wire [DATA_WIDTH-1:0] readdata_mux;


//interrupt mask register
always @ (posedge clk or posedge reset)
begin
  if (reset == 1)
  begin
    irq_mask <= 0;
  end
  else if (irq_mask_wr_strobe)
  begin
    irq_mask <= write_data;    
  end
end

//double registers for asynchronous input and assure metastability
always @ (posedge clk or posedge reset)
begin
  if (reset == 1)
  begin
    data_in_d1 <= 0;
    data_in_d2 <= 0;
  end
  else
  begin
    data_in_d1 <= data_in;
    data_in_d2 <= data_in_d1;
  end
end

//edge detection logic
always @ (posedge clk or posedge reset)
begin
  if (reset == 1)
  begin
    data_in_d3 <= 0;
  end
  else
  begin
    data_in_d3 <= data_in_d2;    
  end
end

assign edge_detect = data_in_d2 & ~data_in_d3; 

//edge capture registers with separate clear bit 
generate
genvar BIT;
for(BIT = 0; BIT < DATA_WIDTH; BIT = BIT + 1)
begin: edge_capture_generation	
  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      edge_capture[BIT] <= 0;
    end
    else 
	begin
	  if (edge_capture_wr_strobe && write_data[BIT])
        edge_capture[BIT] <= 0;
	  else if (edge_detect[BIT])
	    edge_capture[BIT] <= 1;
    end
  end
end
endgenerate

// register the readdata_mux
always @ (posedge clk or posedge reset)
begin
  if (reset == 1)
  begin
    read_data <= 0;
  end
  else
  begin
    read_data <= readdata_mux;    
  end
end


assign readdata_mux = ({DATA_WIDTH{(irq_mask_reg_en == 1'b1)}} & irq_mask) | ({DATA_WIDTH{(edge_capture_reg_en == 1'b1)}} & edge_capture);
assign irq_mask_wr_strobe = (write == 1'b1) && (address_decode == 1'b1) && (irq_mask_reg_en == 1'b1);
assign edge_capture_wr_strobe = (write == 1'b1) && (address_decode == 1'b1) && (edge_capture_reg_en == 1'b1);
assign irq_out = |(edge_capture & irq_mask);

endmodule
