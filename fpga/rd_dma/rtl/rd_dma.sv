import rd_dma_regs_pkg::*;

module rd_dma #(
  parameter int AMM_DMA_DATA_W = 64,
  parameter int AMM_DMA_ADDR_W = 32,

  parameter int AMM_CSR_DATA_W = 32,
  parameter int AMM_CSR_ADDR_W = 4,

  parameter int AST_SOURCE_SYMBOLS = AMM_DMA_DATA_W/8,
  parameter int AST_SOURCE_EMPTY_W = ( AST_SOURCE_SYMBOLS  == 1   ) ?
                                     ( 1                          ) :
                                     ( $clog2(AST_SOURCE_SYMBOLS) )
)(
  input                                        clk_i,
  input                                        srst_i,

  input   [AMM_CSR_ADDR_W-1:0]                 amm_slave_csr_address_i,
  input                                        amm_slave_csr_read_i,
  output logic [AMM_CSR_DATA_W-1:0]                 amm_slave_csr_readdata_o,
  input                                        amm_slave_csr_write_i,
  input   [AMM_CSR_DATA_W-1:0]                 amm_slave_csr_writedata_i,

  output   [AMM_DMA_ADDR_W-1:0]                amm_dma_address_o,
  output                                       amm_dma_read_o,
  input    [AMM_DMA_DATA_W-1:0]                amm_dma_readdata_i,
  input                                        amm_dma_readdata_valid_i,
  input                                        amm_dma_waitreques_i,

  //// Avalon ST source -- intreface for string, that could contain patterns: ////
  output  [AMM_DMA_DATA_W-1:0]                 ast_source_data_o,
  input                                        ast_source_ready_i,
  output                                       ast_source_valid_o,
  output  [AST_SOURCE_EMPTY_W-1:0]             ast_source_empty_o,
  output                                       ast_source_endofpacket_o,
  output                                       ast_source_startofpacket_o,

  output  logic                                end_irq_o
);

logic                      run_rd_stb;
logic [AMM_CSR_DATA_W-1:0] base_addr;
logic [AMM_CSR_DATA_W-1:0] rd_addr;
logic [AMM_CSR_DATA_W-1:0] seneded_cnt;
logic [AMM_CSR_DATA_W-1:0] size;
logic                      done_flag;
logic fifo_almost_full;
logic fifo_empty;
logic rd;
logic rd_done_stb;
logic irq_en;

assign run_rd_stb = ( amm_slave_csr_address_i == RUN ) &&
                    ( amm_slave_csr_write_i          ) &&
                    ( amm_slave_csr_writedata_i[0]   );

always_ff @( posedge clk_i )
  begin
    if( ( amm_slave_csr_write_i                ) && 
        ( amm_slave_csr_address_i == BASE_ADDR ) )
    base_addr <= amm_slave_csr_writedata_i;
  end

always_ff @( posedge clk_i )
  begin
    if( ( amm_slave_csr_write_i           ) && 
        ( amm_slave_csr_address_i == SIZE ) )
    size <= amm_slave_csr_writedata_i;
  end

always_ff @( posedge clk_i )
  begin
    if( ( amm_slave_csr_write_i             ) && 
        ( amm_slave_csr_address_i == IRQ_EN ) )
    irq_en <= amm_slave_csr_writedata_i[0];
  end

always_ff @( posedge clk_i )
  begin
    if( run_rd_stb )
      rd_addr <= base_addr;
    else
      if( amm_dma_read_o && !amm_dma_waitreques_i )
        rd_addr <= rd_addr + 1;
  end

always_ff @( posedge clk_i )
  begin
    if( amm_slave_csr_read_i )
      begin
        amm_slave_csr_readdata_o[0] <=  done_flag;
        amm_slave_csr_readdata_o[AMM_CSR_DATA_W-1:1] <= '0;
      end
  end

assign amm_dma_address_o = rd_addr;


always_ff @( posedge clk_i )
  begin
    if( srst_i )
      rd <= '0;
    else
      begin
        if( rd_done_stb )
          rd <= 1'b0;
        else
          begin
            if( run_rd_stb )
              rd <= 1'b1;
          end
      end
  end


assign amm_dma_read_o = rd && !fifo_almost_full;

assign rd_done_stb = ( amm_dma_address_o == ( base_addr + size ) ) &&
                     ( amm_dma_read_o                            ) &&
                     ( !amm_dma_waitreques_i                     );

assign ast_source_valid_o = !fifo_empty;

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      seneded_cnt <= '0;
    else
      begin
        if( run_rd_stb )
          seneded_cnt <= '0;
        else
          if( ast_source_valid_o && ast_source_ready_i )
            seneded_cnt <= seneded_cnt + 1;
      end
  end

sc_fifo #(
  .DATA_W     ( AMM_DMA_DATA_W                            ),
  .ADDR_W     ( 6                                         )
) output_fifo (
  .clock       ( clk_i                                    ),
  .data        ( amm_dma_readdata_i                       ),
  .rdreq       ( ast_source_ready_i && ast_source_valid_o ),
  .wrreq       ( amm_dma_readdata_valid_i                 ),
  .almost_full ( fifo_almost_full                         ),
  .empty       ( fifo_empty                               ),
  .full        (                                          ),
  .q           ( ast_source_data_o                        ),
  .usedw       (                                          )
);

assign ast_source_empty_o = '0;

assign ast_source_startofpacket_o = (seneded_cnt == '0);
assign ast_source_endofpacket_o   = (seneded_cnt == size);

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      end_irq_o <= 1'b0;
    else
      begin
        if( !irq_en )
          end_irq_o <= 1'b0;
        else
          if( ast_source_endofpacket_o && ast_source_valid_o && ast_source_ready_i )
            end_irq_o <= 1'b1;
      end
  end

always_ff @( posedge clk_i )
  begin
    if( run_rd_stb )
      done_flag <= '0;
    else
      begin
        if( rd_done_stb )
          done_flag <= 1'b1; 
      end
  end

endmodule
