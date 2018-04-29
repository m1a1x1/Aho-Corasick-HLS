`timescale 1ns / 1ns

import rd_dma_regs_pkg::*;

module top_tb;

parameter int AMM_DMA_DATA_W     = 64;
parameter int AMM_DMA_ADDR_W     = 32;
parameter int AMM_DMA_BURST_W    = 11; 
parameter int AMM_DMA_BURST_SIZE = 128;
parameter int AMM_CSR_DATA_W     = 32;
parameter int AMM_CSR_ADDR_W     = 4;
parameter int BYTE_W             = 8;

//// Testbench settings: ////
logic                        clk;
logic                        rst;
bit                          rst_done=0;

logic  [AMM_CSR_ADDR_W-1:0] csr_address;
logic                       csr_read;
logic  [AMM_CSR_DATA_W-1:0] csr_readdata;
logic                       csr_write;
logic  [AMM_CSR_DATA_W-1:0] csr_writedata;

logic  [AMM_DMA_ADDR_W-1:0] amm_dma_address;
logic                       amm_dma_read;

logic  [AMM_DMA_BURST_W-1:0] amm_dma_burstcount;
logic                        amm_dma_beginbursttransfer;
logic  [AMM_DMA_DATA_W-1:0] amm_dma_readdata;
logic                       amm_dma_readdata_valid;
logic                       amm_dma_waitreques;

initial
  begin
    clk = 1'b0;
    forever
      begin
        #10
        clk = ~clk;
      end
  end

initial
  begin
    rst = 1'b0;
    #19
    @( posedge clk )
    rst = 1'b1;
    #39
    @( posedge clk )
    rst = 1'b0;
    @( posedge clk )
    rst_done = 1'b1;
  end

//********************************************************************
//****************************** DUT *********************************
rd_dma #(
  .AMM_DMA_DATA_W               ( AMM_DMA_DATA_W             ),
  .AMM_DMA_ADDR_W               ( AMM_DMA_ADDR_W             ),
  .AMM_DMA_BURST_W              ( AMM_DMA_BURST_W            ),
  .AMM_DMA_BURST_SIZE           ( AMM_DMA_BURST_SIZE         ),
  .AMM_CSR_DATA_W               ( AMM_CSR_DATA_W             ),
  .AMM_CSR_ADDR_W               ( AMM_CSR_ADDR_W             )
) dut (
  .clk_i                        ( clk                        ),
  .srst_i                       ( rst                        ),

  .amm_slave_csr_address_i      ( csr_address                ),
  .amm_slave_csr_read_i         ( csr_read                   ),
  .amm_slave_csr_readdata_o     ( csr_readdata               ),
  .amm_slave_csr_write_i        ( csr_write                  ),
  .amm_slave_csr_writedata_i    ( csr_writedata              ),

  .amm_dma_address_o            ( amm_dma_address            ),
  .amm_dma_read_o               ( amm_dma_read               ),
  .amm_dma_burstcount_o         ( amm_dma_burstcount         ),
  .amm_dma_beginbursttransfer_o ( amm_dma_beginbursttransfer ),
  .amm_dma_readdata_i           ( amm_dma_readdata           ),
  .amm_dma_readdata_valid_i     ( amm_dma_readdata_valid     ),
  .amm_dma_waitreques_i         ( amm_dma_waitreques         ),

  .ast_source_valid_o           (                            ),
  .ast_source_ready_i           ( 1'b1                       ),
  .ast_source_data_o            (                            ),
  .ast_source_empty_o           (                            ),
  .ast_source_startofpacket_o   (                            ),
  .ast_source_endofpacket_o     (                            )
);

//********************************************************************
//************************* TASKS and FUNCTIONS **********************

task csr_read_t( input  bit [AMM_CSR_ADDR_W-1:0] addr, 
                 output bit [AMM_CSR_DATA_W-1:0] value
              );
  csr_address   <= '0;        
  csr_writedata <= '0;
  csr_write     <= '0;
  csr_read      <= '0;
  @( posedge clk );
  csr_address   <= addr;        
  csr_read      <= 1'b1;
  @( posedge clk );
  csr_read      <= 1'b0;
  @( posedge clk );
  value         = csr_readdata;
endtask

task csr_write_t( input bit [AMM_CSR_ADDR_W-1:0] addr, 
                      bit [AMM_CSR_DATA_W-1:0] value
                );
  csr_address   <= '0;        
  csr_writedata <= '0;
  csr_write     <= '0;
  csr_read      <= '0;
  @( posedge clk );
  csr_address   <= addr;        
  csr_writedata <= value;
  csr_write     <= 1'b1;
  @( posedge clk );
  csr_write     <= 1'b0;
endtask

task csr_wait_t( input bit [AMM_CSR_ADDR_W-1:0] addr, 
                     bit [AMM_CSR_DATA_W-1:0] value
              );
  bit [AMM_CSR_DATA_W-1:0] reg_value;

  do
    begin
      repeat (50) @( posedge clk );
      csr_read_t( addr, reg_value );
    end
  while( reg_value != value );
endtask

// Config Bloom Filter:
// Clean hash lut and write hash lut memory dump from file:
task config_t( );
  csr_write_t( BASE_ADDR, 32'h12345678 );
  csr_write_t( SIZE, 34 );
  csr_write_t( IRQ_EN, 1'b1 );
  csr_write_t( RUN, 1'b1 );
endtask

always_ff @( posedge clk )
  begin
    amm_dma_readdata_valid <= amm_dma_read;
    amm_dma_readdata       <= $urandom_range(2**32,0); 
  end

assign amm_dma_waitreques = 1'b0;
//********************************************************************
//************************* MAIN FLOW ********************************

initial
  begin
    wait( rst_done )
    config_t( );
    $display( "Test done, No errors" );
    //$stop();
  end

endmodule
