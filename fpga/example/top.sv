
module top(


	//////////// CLOCK //////////
	input 		          		fpga_clk0_50,
	input 		          		fpga_clk1_50,
	input 		          		fpga_clk2_50,

	//////////// HPS //////////
	/* 3.3-V LVTTL */
	inout 		          		HPS_CONV_USB_N,
	
	/* SSTL-15 Class I */
	output		    [14:0]		HPS_DDR3_ADDR,
	output		     [2:0]		HPS_DDR3_BA,
	output		          		HPS_DDR3_CAS_N,
	output		          		HPS_DDR3_CKE,
	output		          		HPS_DDR3_CS_N,
	output		     [3:0]		HPS_DDR3_DM,
	inout 		    [31:0]		HPS_DDR3_DQ,
	output		          		HPS_DDR3_ODT,
	output		          		HPS_DDR3_RAS_N,
	output		          		HPS_DDR3_RESET_N,
	input 		          		HPS_DDR3_RZQ,
	output		          		HPS_DDR3_WE_N,
	/* DIFFERENTIAL 1.5-V SSTL CLASS I */
	output		          		HPS_DDR3_CK_N,
	output		          		HPS_DDR3_CK_P,
	inout 		     [3:0]		HPS_DDR3_DQS_N,
	inout 		     [3:0]		HPS_DDR3_DQS_P,
	
	/* 3.3-V LVTTL */
	output		          		HPS_ENET_GTX_CLK,
	inout 		          		HPS_ENET_INT_N,
	output		          		HPS_ENET_MDC,
	inout 		          		HPS_ENET_MDIO,
	input 		          		HPS_ENET_RX_CLK,
	input 		     [3:0]		HPS_ENET_RX_DATA,
	input 		          		HPS_ENET_RX_DV,
	output		     [3:0]		HPS_ENET_TX_DATA,
	output		          		HPS_ENET_TX_EN,
	inout 		          		HPS_GSENSOR_INT,
	inout 		          		HPS_I2C0_SCLK,
	inout 		          		HPS_I2C0_SDAT,
	inout 		          		HPS_I2C1_SCLK,
	inout 		          		HPS_I2C1_SDAT,
	inout 		          		HPS_KEY,
	inout 		          		HPS_LED,
	inout 		          		HPS_LTC_GPIO,
	output		          		HPS_SD_CLK,
	inout 		          		HPS_SD_CMD,
	inout 		     [3:0]		HPS_SD_DATA,
	output		          		HPS_SPIM_CLK,
	input 		          		HPS_SPIM_MISO,
	output		          		HPS_SPIM_MOSI,
	inout 		          		HPS_SPIM_SS,
	input 		          		HPS_UART_RX,
	output		          		HPS_UART_TX,
//	input 		          		HPS_USB_CLKOUT,
//	inout 		     [7:0]		HPS_USB_DATA,
//	input 		          		HPS_USB_DIR,
//	input 		          		HPS_USB_NXT,
//	output		          		HPS_USB_STP,
	
	//////////// KEY ////////////
	/* 3.3-V LVTTL */
	input				[1:0]			key,
	
	//////////// LED ////////////
	/* 3.3-V LVTTL */
	output			[7:0]			led,
	
	//////////// SW ////////////
	/* 3.3-V LVTTL */
	input				[3:0]			sw
);


logic [7:0] led_tmp;
logic [1:0] ready;
logic [7:0] str_out_data;

soc_system soc(
 	//Clock&Reset
   .clk_clk                               (fpga_clk0_50 ),                               //                            clk.clk
   //HPS ddr3
   .memory_mem_a                          ( HPS_DDR3_ADDR),                       //                memory.mem_a
   .memory_mem_ba                         ( HPS_DDR3_BA),                         //                .mem_ba
   .memory_mem_ck                         ( HPS_DDR3_CK_P),                       //                .mem_ck
   .memory_mem_ck_n                       ( HPS_DDR3_CK_N),                       //                .mem_ck_n
   .memory_mem_cke                        ( HPS_DDR3_CKE),                        //                .mem_cke
   .memory_mem_cs_n                       ( HPS_DDR3_CS_N),                       //                .mem_cs_n
   .memory_mem_ras_n                      ( HPS_DDR3_RAS_N),                      //                .mem_ras_n
   .memory_mem_cas_n                      ( HPS_DDR3_CAS_N),                      //                .mem_cas_n
   .memory_mem_we_n                       ( HPS_DDR3_WE_N),                       //                .mem_we_n
   .memory_mem_reset_n                    ( HPS_DDR3_RESET_N),                    //                .mem_reset_n
   .memory_mem_dq                         ( HPS_DDR3_DQ),                         //                .mem_dq
   .memory_mem_dqs                        ( HPS_DDR3_DQS_P),                      //                .mem_dqs
   .memory_mem_dqs_n                      ( HPS_DDR3_DQS_N),                      //                .mem_dqs_n
   .memory_mem_odt                        ( HPS_DDR3_ODT),                        //                .mem_odt
   .memory_mem_dm                         ( HPS_DDR3_DM),                         //                .mem_dm
   .memory_oct_rzqin                      ( HPS_DDR3_RZQ),                        //                .oct_rzqin                                  
   //HPS ethernet		
   .hps_0_hps_io_hps_io_emac1_inst_TX_CLK ( HPS_ENET_GTX_CLK),       //                             hps_0_hps_io.hps_io_emac1_inst_TX_CLK
   .hps_0_hps_io_hps_io_emac1_inst_TXD0   ( HPS_ENET_TX_DATA[0] ),   //                             .hps_io_emac1_inst_TXD0
   .hps_0_hps_io_hps_io_emac1_inst_TXD1   ( HPS_ENET_TX_DATA[1] ),   //                             .hps_io_emac1_inst_TXD1
   .hps_0_hps_io_hps_io_emac1_inst_TXD2   ( HPS_ENET_TX_DATA[2] ),   //                             .hps_io_emac1_inst_TXD2
   .hps_0_hps_io_hps_io_emac1_inst_TXD3   ( HPS_ENET_TX_DATA[3] ),   //                             .hps_io_emac1_inst_TXD3
   .hps_0_hps_io_hps_io_emac1_inst_RXD0   ( HPS_ENET_RX_DATA[0] ),   //                             .hps_io_emac1_inst_RXD0
   .hps_0_hps_io_hps_io_emac1_inst_MDIO   ( HPS_ENET_MDIO ),         //                             .hps_io_emac1_inst_MDIO
   .hps_0_hps_io_hps_io_emac1_inst_MDC    ( HPS_ENET_MDC  ),         //                             .hps_io_emac1_inst_MDC
   .hps_0_hps_io_hps_io_emac1_inst_RX_CTL ( HPS_ENET_RX_DV),         //                             .hps_io_emac1_inst_RX_CTL
   .hps_0_hps_io_hps_io_emac1_inst_TX_CTL ( HPS_ENET_TX_EN),         //                             .hps_io_emac1_inst_TX_CTL
   .hps_0_hps_io_hps_io_emac1_inst_RX_CLK ( HPS_ENET_RX_CLK),        //                             .hps_io_emac1_inst_RX_CLK
   .hps_0_hps_io_hps_io_emac1_inst_RXD1   ( HPS_ENET_RX_DATA[1] ),   //                             .hps_io_emac1_inst_RXD1
   .hps_0_hps_io_hps_io_emac1_inst_RXD2   ( HPS_ENET_RX_DATA[2] ),   //                             .hps_io_emac1_inst_RXD2
   .hps_0_hps_io_hps_io_emac1_inst_RXD3   ( HPS_ENET_RX_DATA[3] ),   //                             .hps_io_emac1_inst_RXD3		  
   //HPS SD card 
   .hps_0_hps_io_hps_io_sdio_inst_CMD     ( HPS_SD_CMD    ),           //                               .hps_io_sdio_inst_CMD
   .hps_0_hps_io_hps_io_sdio_inst_D0      ( HPS_SD_DATA[0]     ),      //                               .hps_io_sdio_inst_D0
   .hps_0_hps_io_hps_io_sdio_inst_D1      ( HPS_SD_DATA[1]     ),      //                               .hps_io_sdio_inst_D1
   .hps_0_hps_io_hps_io_sdio_inst_CLK     ( HPS_SD_CLK   ),            //                               .hps_io_sdio_inst_CLK
   .hps_0_hps_io_hps_io_sdio_inst_D2      ( HPS_SD_DATA[2]     ),      //                               .hps_io_sdio_inst_D2
   .hps_0_hps_io_hps_io_sdio_inst_D3      ( HPS_SD_DATA[3]     ),      //                               .hps_io_sdio_inst_D3
   //HPS USB 		  
//   .hps_0_hps_io_hps_io_usb1_inst_D0      ( HPS_USB_DATA[0]    ),      //                               .hps_io_usb1_inst_D0
//   .hps_0_hps_io_hps_io_usb1_inst_D1      ( HPS_USB_DATA[1]    ),      //                               .hps_io_usb1_inst_D1
//   .hps_0_hps_io_hps_io_usb1_inst_D2      ( HPS_USB_DATA[2]    ),      //                               .hps_io_usb1_inst_D2
//   .hps_0_hps_io_hps_io_usb1_inst_D3      ( HPS_USB_DATA[3]    ),      //                               .hps_io_usb1_inst_D3
//   .hps_0_hps_io_hps_io_usb1_inst_D4      ( HPS_USB_DATA[4]    ),      //                               .hps_io_usb1_inst_D4
//   .hps_0_hps_io_hps_io_usb1_inst_D5      ( HPS_USB_DATA[5]    ),      //                               .hps_io_usb1_inst_D5
//   .hps_0_hps_io_hps_io_usb1_inst_D6      ( HPS_USB_DATA[6]    ),      //                               .hps_io_usb1_inst_D6
//   .hps_0_hps_io_hps_io_usb1_inst_D7      ( HPS_USB_DATA[7]    ),      //                               .hps_io_usb1_inst_D7
//   .hps_0_hps_io_hps_io_usb1_inst_CLK     ( HPS_USB_CLKOUT    ),       //                               .hps_io_usb1_inst_CLK
//   .hps_0_hps_io_hps_io_usb1_inst_STP     ( HPS_USB_STP    ),          //                               .hps_io_usb1_inst_STP
//   .hps_0_hps_io_hps_io_usb1_inst_DIR     ( HPS_USB_DIR    ),          //                               .hps_io_usb1_inst_DIR
//   .hps_0_hps_io_hps_io_usb1_inst_NXT     ( HPS_USB_NXT    ),          //                               .hps_io_usb1_inst_NXT
 	//HPS SPI 		  
   .hps_0_hps_io_hps_io_spim1_inst_CLK    ( HPS_SPIM_CLK  ),           //                               .hps_io_spim1_inst_CLK
   .hps_0_hps_io_hps_io_spim1_inst_MOSI   ( HPS_SPIM_MOSI ),           //                               .hps_io_spim1_inst_MOSI
   .hps_0_hps_io_hps_io_spim1_inst_MISO   ( HPS_SPIM_MISO ),           //                               .hps_io_spim1_inst_MISO
   .hps_0_hps_io_hps_io_spim1_inst_SS0    ( HPS_SPIM_SS   ),             //                               .hps_io_spim1_inst_SS0
 	//HPS UART		
   .hps_0_hps_io_hps_io_uart0_inst_RX     ( HPS_UART_RX   ),          //                               .hps_io_uart0_inst_RX
   .hps_0_hps_io_hps_io_uart0_inst_TX     ( HPS_UART_TX   ),          //                               .hps_io_uart0_inst_TX
 	//HPS I2C1
   .hps_0_hps_io_hps_io_i2c0_inst_SDA     ( HPS_I2C0_SDAT  ),        //                               .hps_io_i2c0_inst_SDA
   .hps_0_hps_io_hps_io_i2c0_inst_SCL     ( HPS_I2C0_SCLK  ),        //                               .hps_io_i2c0_inst_SCL
 	//HPS I2C2
   .hps_0_hps_io_hps_io_i2c1_inst_SDA     ( HPS_I2C1_SDAT  ),        //                               .hps_io_i2c1_inst_SDA
   .hps_0_hps_io_hps_io_i2c1_inst_SCL     ( HPS_I2C1_SCLK  ),        //                               .hps_io_i2c1_inst_SCL
 	//GPIO 
   .hps_0_hps_io_hps_io_gpio_inst_GPIO09  ( HPS_CONV_USB_N ),  //                               .hps_io_gpio_inst_GPIO09
   .hps_0_hps_io_hps_io_gpio_inst_GPIO35  ( HPS_ENET_INT_N ),  //                               .hps_io_gpio_inst_GPIO35
   .hps_0_hps_io_hps_io_gpio_inst_GPIO40  ( HPS_LTC_GPIO   ),  //                               .hps_io_gpio_inst_GPIO40
   .hps_0_hps_io_hps_io_gpio_inst_GPIO53  ( HPS_LED   ),  //                               .hps_io_gpio_inst_GPIO53
   .hps_0_hps_io_hps_io_gpio_inst_GPIO54  ( HPS_KEY   ),  //                               .hps_io_gpio_inst_GPIO54
   .hps_0_hps_io_hps_io_gpio_inst_GPIO61  ( HPS_GSENSOR_INT ),  //                               .hps_io_gpio_inst_GPIO61
 	//FPGA Partion
  .str_out_data          ( str_out_data          ),
  .str_out_ready         (  &ready               ),
  .str_out_valid         ( str_out_valid         ),
  .str_out_startofpacket ( str_out_startofpacket ),
  .str_out_endofpacket   ( str_out_endofpacket   ),

  .str_in0_data          ( str_out_data          ),
  .str_in0_ready         ( ready[0]              ),
  .str_in0_valid         ( str_out_valid         ),
  .str_in0_startofpacket ( str_out_startofpacket ),
  .str_in0_endofpacket   ( str_out_endofpacket   ),

  .str_in1_data          ( str_out_data          ),
  .str_in1_ready         ( ready[1]              ),
  .str_in1_valid         ( str_out_valid         ),
  .str_in1_startofpacket ( str_out_startofpacket ),
  .str_in1_endofpacket   ( str_out_endofpacket   ),

/*
  .test_0_call0_valid ( str_out_valid || led_tmp[7]  ),
  .test_0_call0_stall ( ready[0]              ),
  .test_0_call1_valid ( str_out_valid  || led_tmp[7]       ),
  .test_0_call1_stall ( ready[1]              ),
  .test_0_ret0_valid  (                       ),
  .test_0_ret0_stall  (                       ),
  .test_0_ret1_valid  (                       ),
  .test_0_ret1_stall  (                            ),
  .test_0_sop0_data   ( str_out_startofpacket      ),
  .test_0_sop1_data   ( str_out_startofpacket      ),
  .test_0_symbol0_data( str_out_data          ),
  .test_0_symbol1_data( str_out_data          ),

*/
  .led_export         ( led_tmp[7:0]        )
);

localparam FREQ = 50000000;
logic [31:0] cnt = 0;


always_ff @( posedge fpga_clk0_50 )
  begin
    if( cnt == FREQ )
      cnt <= '0;
    else
      cnt <= cnt + 1'b1;
  end 

assign led = {( cnt < ( FREQ/2 ) ), led_tmp[6:0]}; 

endmodule
