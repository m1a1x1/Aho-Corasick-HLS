module am_ch_byteorder #(
  parameter DATA_WIDTH = 64,
  parameter ADDR_WIDTH = 32,
  parameter BURST_WIDTH = 8 
)(

 output [DATA_WIDTH-1:0]    mst_writedata,
 output                     mst_write,
 input [DATA_WIDTH-1:0]     mst_readdata,
 input                      mst_readdata_valid,
 output                     mst_read,
 input                      mst_waitrequest,
 output [ADDR_WIDTH-1:0]    mst_address,
 output [BURST_WIDTH-1:0]   mst_burstcount,
 output logic [DATA_WIDTH/8 -1:0] mst_byteenable,
  

 input [DATA_WIDTH-1:0]    slv_writedata,
 input                     slv_write,
 output [DATA_WIDTH-1:0]   slv_readdata,
 output                    slv_readdata_valid,
 input                     slv_read,
 output                    slv_waitrequest,
 input [ADDR_WIDTH-1:0]    slv_address,
 input [BURST_WIDTH-1:0]   slv_burstcount,
 input [DATA_WIDTH/8 -1:0] slv_byteenable,

 input                    clk_i,
 input                    rst_i
);
localparam BYTES = DATA_WIDTH/8;

logic [BYTES-1:0][7:0] wr_data, wr_data_reorder;
logic [BYTES-1:0][7:0] rd_data, rd_data_reorder;

assign wr_data = slv_writedata;
assign rd_data = mst_readdata;

always_comb
  for( int i = 0; i < BYTES; i++ )
    begin
      wr_data_reorder[BYTES-1-i] = wr_data[i];
      rd_data_reorder[BYTES-1-i] = rd_data[i];
      mst_byteenable[BYTES-1-i]  = slv_byteenable[i];
    end

assign mst_writedata = wr_data_reorder;
assign slv_readdata  = rd_data_reorder;

assign mst_write = slv_write;
assign mst_read = slv_read;
assign slv_readdata_valid = mst_readdata_valid;
assign slv_waitrequest  =  mst_waitrequest;
assign mst_address = slv_address;
endmodule
