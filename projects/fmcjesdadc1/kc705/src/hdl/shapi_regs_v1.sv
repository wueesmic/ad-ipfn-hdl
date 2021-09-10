//////////////////////////////////////////////////////////////////////////////////
// Company: IPFN-IST
// Engineer: BBC
//
// Create Date: 05/08/2021 07:21:01 PM
// Design Name:
// Module Name: shapi_regs_v1
// Project Name:
// Target Devices: kintex-7
// Tool Versions:  Vivado 2019.1
// Description: Creates data packages for xdma engine in 32 /16 data format
// also computes Intergal of adc signal, the "F" function algorithm an
// derivative.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// Copyright 2015 - 2021 IPFN-Instituto Superior Tecnico, Portugal
// Creation Date  2017-11-09
//
// Licensed under the EUPL, Version 1.2 or - as soon they
// will be approved by the European Commission - subsequent
// versions of the EUPL (the "Licence");
// You may not use this work except in compliance with the
// Licence.
// You may obtain a copy of the Licence at:
//
// https://joinup.ec.europa.eu/software/page/eupl
//
// Unless required by applicable law or agreed to in
// writing, software distributed under the Licence is
// distributed on an "AS IS" basis,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied.
// See the Licence for the specific language governing
// permissions and limitations under the Licence.
//
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps
`include "shapi_stdrt_dev_inc.vh"

module shapi_regs_v1 #
    (
        // Users to add parameters here

        // User parameters ends
        // Do not modify the parameters beyond this line

        // Width of S_AXI data bus
        parameter integer C_S_AXI_DATA_WIDTH    = 32,
        // Width of S_AXI address busslv_reg89
        parameter integer C_S_AXI_ADDR_WIDTH    = 8,

        parameter TCQ        = 1

    )
    (
        // Users to add ports here

        // User ports ends
        // Do not modify the ports beyond this line

        // Global Clock Signal
        input wire  S_AXI_ACLK,
        // Global Reset Signal. This Signal is Active LOW
        input wire  S_AXI_ARESETN,
        // Write address (issued by master, acceped by Slave)
        input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
        // Write channel Protection type. This signal indicates the
            // privilege and security level of the transaction, and whether
            // the transaction is a data access or an instruction access.
        // input wire [2 : 0] S_AXI_AWPROT,
        // Write address valid. This signal indicates that the master signaling
            // valid write address and control information.
        input wire  S_AXI_AWVALID,
        // Write address ready. This signal indicates that the slave is ready
            // to accept an address and associated control signals.
        output wire  S_AXI_AWREADY,
        // Write data (issued by master, acceped by Slave)
        input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
        // Write strobes. This signal indicates which byte lanes hold
            // valid data. There is one write strobe bit for each eight
            // bits of the write data bus.
        input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
        // Write valid. This signal indicates that valid write
            // data and strobes are available.
        input wire  S_AXI_WVALID,
        // Write ready. This signal indicates that the slave
            // can accept the write data.
        output wire  S_AXI_WREADY,
        // Write response. This signal indicates the status
            // of the write transaction.
        output wire [1 : 0] S_AXI_BRESP,
        // Write response valid. This signal indicates that the channel
            // is signaling a valid write response.
        output wire  S_AXI_BVALID,
        // Response ready. This signal indicates that the master
            // can accept a write response.
        input wire  S_AXI_BREADY,
        // Read address (issued by master, acceped by Slave)
        input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
        // Protection type. This signal indicates the privilege
            // and security level of the transaction, and whether the
            // transaction is a data access or an instruction access.
        // input wire [2 : 0] S_AXI_ARPROT,
        // Read address valid. This signal indicates that the channel
            // is signaling valid read address and control information.
        input wire  S_AXI_ARVALID,
        // Read address ready. This signal indicates that the slave is
            // ready to accept an address and associated control signals.
        output wire  S_AXI_ARREADY,
        // Read data (issued by slave)
        output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
        // Read response. This signal indicates the status of the
            // read transfer.
        output wire [1 : 0] S_AXI_RRESP,
        // Read valid. This signal indicates that the channel is
            // signaling the required read data.
        output wire  S_AXI_RVALID,
        // Read ready. This signal indicates that the master can
            // accept the read data and response information.
        input wire  S_AXI_RREADY,

            //ADC Port
        input       [31:0]  status_reg,
        output      [31:0]  control_reg

    );


/********IPFN reg ***********/

    reg   [31:0]     control_r;

 //#### STANDARD DEVICE  ######//
    wire        dev_endian_status = control_r[10];  // 1'b0;        //offset_addr 0x28 '0' - little-endian format.
    wire        dev_rtm_status = 1'b0;           //offset_addr 0x28
    wire        dev_soft_rst_status = 1'b0;      //offset_addr 0x28
    wire        dev_full_rst_status = 1'b0;      //offset_addr 0x28

    //#### STANDARD DEVICE REGISTERS ######//
    reg  [31:0] dev_interrupt_mask_r ;   // pcie_regs_r[12];          //offset_addr 0x30
    wire [31:0] dev_interrupt_flag    = dev_interrupt_mask_r;       //offset_addr 0x34
    reg  [31:0] dev_interrupt_active_r; // = 32'h0;                    //offset_addr 0x38
    reg  [31:0] dev_scratch_reg  ;//      = 32'h0;          //offset_addr 0x3c

    reg  [31:1] dev_control_r        = 31'h0;  //offset_addr 0x2c
    wire  dev_endian_control   = control_r[10]; // dev_control_r[`DEV_CNTRL_ENDIAN_BIT];
    wire  dev_soft_rst_control = dev_control_r[`DEV_CNTRL_SFT_RST_BIT];
    wire  dev_full_rst_control = dev_control_r[`DEV_CNTRL_FULL_RST_BIT];


    //#### MODULE REGISTERS ######//
    wire [63:0] mod_name = `MOD_DMA_NAME; // Two words

    reg [31:30]  mod_control_r = 2'h0;
    wire   mod_soft_rst_control = mod_control_r[`MOD_CNTRL_SFT_RST_BIT];       //offset_addr 0x2c
    wire   mod_full_rst_control = mod_control_r[`MOD_CNTRL_FULL_RST_BIT];       //offset_addr 0x2c

    reg [31:0]  mod_interrupt_flag_clear_r  = 32'h0;
    localparam        MOD_SOFT_RST_STATUS = 1'b0;                       //offset_addr 0x28
    localparam        MOD_FULL_RST_STATUS = 1'b0;                       //offset_addr 0x28

    reg [31:0]  mod_interrupt_mask_r  = 32'h0;
    localparam  MOD_INTERRUPT_FLAG   = 32'h0; //mod1_interrupt_mask;                //offset_addr 0x34
    localparam  MOD_INTERRUPT_ACTIVE = 32'h0;     //offset_addr 0x38



    assign control_reg = control_r;


    /*********************/
    // AXI4LITE signals
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_awaddr;
    reg     axi_awready;
    reg     axi_wready;
    reg [1 : 0]     axi_bresp;
    reg     axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_araddr;
    reg     axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0]  axi_rdata;
    reg [1 : 0]     axi_rresp;
    reg     axi_rvalid;

    // Example-specific design signals
    // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
    // ADDR_LSB is used for addressing 32/64 bit registers/memories
    // ADDR_LSB = 2 for 32 bits (n downto 2)
    // ADDR_LSB = 3 for 64 bits (n downto 3)
    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 5;
    //----------------------------------------------
    //-- Signals for user logic register space example
    //------------------------------------------------
    //-- Number of Slave Registers 64
    //reg [C_S_AXI_DATA_WIDTH-1:0]  slv_reg15;
    //reg [C_S_AXI_DATA_WIDTH-1:0]  slv_reg89;
//  reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg127;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg00;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg01;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg02;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg03;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg04;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg05;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg06;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg07;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg08;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg09;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg10;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg11;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg12;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg13;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg14;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg15;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg16;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg17;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg18;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg19;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg20;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg21;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg22;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg23;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg24;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg25;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg26;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg27;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg28;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg29;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg30;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg31;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg32;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg33;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg34;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg35;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg36;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg37;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg38;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg39;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg40;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg41;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg42;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg43;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg44;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg45;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg46;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg47;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg48;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg49;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg50;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg51;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg52;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg53;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg54;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg55;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg56;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg57;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg58;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg59;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg60;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg61;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg62;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg63;
    wire     slv_reg_rden;
    wire     slv_reg_wren;
    reg [C_S_AXI_DATA_WIDTH-1:0]     reg_data_out;
    integer  byte_index;
    reg  aw_en;

    // I/O Connections assignments

    assign S_AXI_AWREADY    = axi_awready;
    assign S_AXI_WREADY = axi_wready;
    assign S_AXI_BRESP  = axi_bresp;
    assign S_AXI_BVALID = axi_bvalid;
    assign S_AXI_ARREADY    = axi_arready;
    assign S_AXI_RDATA  = axi_rdata;
    assign S_AXI_RRESP  = axi_rresp;
    assign S_AXI_RVALID = axi_rvalid;

// Implement axi_awready generation
    // axi_awready is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
    // de-asserted when reset is low.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_awready <= 1'b0;
          aw_en <= 1'b1;
        end
      else
        begin
          if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            begin
              // slave is ready to accept write address when
              // there is a valid write address and write data
              // on the write address and data bus. This design
              // expects no outstanding transactions.
              axi_awready <= 1'b1;
              aw_en <= 1'b0;
            end
            else if (S_AXI_BREADY && axi_bvalid)
                begin
                  aw_en <= 1'b1;
                  axi_awready <= 1'b0;
                end
          else
            begin
              axi_awready <= 1'b0;
            end
        end
    end

    // Implement axi_awaddr latching
    // This process is used to latch the address when both
    // S_AXI_AWVALID and S_AXI_WVALID are valid.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_awaddr <= 0;
        end
      else
        begin
          if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            begin
              // Write Address latching
              axi_awaddr <= S_AXI_AWADDR;
            end
        end
    end

    // Implement axi_wready generation
    // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is
    // de-asserted when reset is low.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_wready <= 1'b0;
        end
      else
        begin
          if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
            begin
              // slave is ready to accept write data when
              // there is a valid write address and write data
              // on the write address and data bus. This design
              // expects no outstanding transactions.
              axi_wready <= 1'b1;
            end
          else
            begin
              axi_wready <= 1'b0;
            end
        end
    end

    // Implement memory mapped register select and write logic generation
    // The write data is accepted and written to memory mapped registers when
    // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
    // select byte enables of slave registers while writing.
    // These registers are cleared when reset (active low) is applied.
    // Slave register write enable is asserted when valid address and data are available
    // and the slave is ready to accept the write address and write data.
    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
            dev_scratch_reg <=  32'hBB;
            dev_control_r   <= 31'h0;
            control_r       <=  32'h00;

          slv_reg00 <= 0;
          slv_reg01 <= 0;
          slv_reg02 <= 0;
          slv_reg03 <= 0;
          slv_reg04 <= 0;
          slv_reg05 <= 0;
          slv_reg06 <= 0;
          slv_reg07 <= 0;
          slv_reg08 <= 0;
          slv_reg09 <= 0;
          slv_reg10 <= 0;
          slv_reg11 <= 0;
          slv_reg12 <= 0;
          slv_reg13 <= 0;
          slv_reg14 <= 0;
          slv_reg15 <= 0;
          slv_reg16 <= 0;
          slv_reg17 <= 0;
          slv_reg18 <= 0;
          slv_reg19 <= 0;
          slv_reg20 <= 0;
          slv_reg21 <= 0;
          slv_reg22 <= 0;
          slv_reg23 <= 0;
          slv_reg24 <= 0;
          slv_reg25 <= 0;
          slv_reg26 <= 0;
          slv_reg27 <= 0;
          slv_reg28 <= 0;
          slv_reg29 <= 0;
          slv_reg30 <= 0;
          slv_reg31 <= 0;
          slv_reg32 <= 0;
          slv_reg33 <= 0;
          slv_reg34 <= 0;
          slv_reg35 <= 0;
          slv_reg36 <= 0;
          slv_reg37 <= 0;
          slv_reg38 <= 0;
          slv_reg39 <= 0;
          slv_reg40 <= 0;
          slv_reg41 <= 0;
          slv_reg42 <= 0;
          slv_reg43 <= 0;
          slv_reg44 <= 0;
          slv_reg45 <= 0;
          slv_reg46 <= 0;
          slv_reg47 <= 0;
          slv_reg48 <= 0;
          slv_reg49 <= 0;
          slv_reg50 <= 0;
          slv_reg51 <= 0;
          slv_reg52 <= 0;
          slv_reg53 <= 0;
          slv_reg54 <= 0;
          slv_reg55 <= 0;
        end
      else begin
        if (slv_reg_wren)
          begin
            case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
              6'h00F: dev_scratch_reg <= S_AXI_WDATA; // BAR 0 regs

                    (`MOD_DMA_REG_OFF + 6'h08): mod_control_r  <= S_AXI_WDATA[31:30];
                    (`MOD_DMA_REG_OFF + 6'h0A): mod_interrupt_flag_clear_r  <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h0B): mod_interrupt_mask_r        <= S_AXI_WDATA;
            //(`MOD_DMA_REG_OFF + 6'h09):
                    (`MOD_DMA_REG_OFF + 6'h10): slv_reg32             <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h11): control_r             <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h12): slv_reg34             <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h13): slv_reg35             <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h14): slv_reg36             <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h15): slv_reg37             <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h16): slv_reg38             <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h17): slv_reg39             <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h18): slv_reg40             <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h19): slv_reg41             <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h1A): slv_reg42             <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h1B): slv_reg43             <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h1C): slv_reg44             <= S_AXI_WDATA;
//                    (`MOD_DMA_REG_OFF + 6'h12): dma_size_r            <= S_AXI_WDATA[23:0]; // DMA Byte Size
//            (`MOD_DMA_REG_OFF + 6'h13): dma_prog_thresh_r     <= S_AXI_WDATA[23:5]; // DMA Byte Size
/**
                    (`MOD_DMA_REG_OFF + 6'h30): eo_offset_r[17:0]     <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h31): eo_offset_r[35:18]    <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h32): eo_offset_r[53:36]    <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h33): eo_offset_r[71:54]    <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h34): eo_offset_r[89:72]    <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h35): eo_offset_r[107:90]   <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h36): eo_offset_r[125:108]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h37): eo_offset_r[143:126]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h38): eo_offset_r[161:144]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h39): eo_offset_r[179:162]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h3A): eo_offset_r[197:180]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h3B): eo_offset_r[215:198]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h3C): eo_offset_r[233:216]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h3D): eo_offset_r[251:234]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h3E): eo_offset_r[269:252]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h3F): eo_offset_r[287:270]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h40): eo_offset_r[305:288]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h41): eo_offset_r[323:306]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h42): eo_offset_r[341:324]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h43): eo_offset_r[359:342]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h44): eo_offset_r[377:360]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h45): eo_offset_r[395:378]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h46): eo_offset_r[413:396]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h47): eo_offset_r[431:414]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h48): eo_offset_r[449:432]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h49): eo_offset_r[467:450]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h4A): eo_offset_r[485:468]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h4B): eo_offset_r[503:486]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h4C): eo_offset_r[521:504]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h4D): eo_offset_r[539:522]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h4E): eo_offset_r[557:540]  <= S_AXI_WDATA[17:0];
                    (`MOD_DMA_REG_OFF + 6'h4F): eo_offset_r[575:558]  <= S_AXI_WDATA[17:0];

                    (`MOD_DMA_REG_OFF + 6'h50): wo_offset_r[31:0]     <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h51): wo_offset_r[63:32]    <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h52): wo_offset_r[95:64]    <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h53): wo_offset_r[127:96]   <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h54): wo_offset_r[159:128]  <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h55): wo_offset_r[191:160]  <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h56): wo_offset_r[223:192]  <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h57): wo_offset_r[255:224]  <= S_AXI_WDATA;

                    (`MOD_DMA_REG_OFF + 6'h60): ilck_param_r[31:0]     <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h61): ilck_param_r[63:32]    <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h62): ilck_param_r[95:64]    <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h63): ilck_param_r[127:96]   <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h64): ilck_param_r[159:128]  <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h65): ilck_param_r[191:160]  <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h66): ilck_param_r[223:192]  <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h67): ilck_param_r[255:224]  <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h68): ilck_param_r[287:256]  <= S_AXI_WDATA;
                    (`MOD_DMA_REG_OFF + 6'h69): ilck_param_r[319:288]  <= S_AXI_WDATA;
                    
*/

            //
            //(`MOD_DMA_REG_OFF + 6'h15): dma_prog_thresh_r     <= post_wr_data[20:5]; // DMA Byte Size
              default : begin
                          slv_reg28 <= slv_reg28;
                          slv_reg29 <= slv_reg29;
                          slv_reg30 <= slv_reg30;
                          slv_reg31 <= slv_reg31;
                          slv_reg32 <= slv_reg32;
                          slv_reg33 <= slv_reg33;
                          slv_reg34 <= slv_reg34;
                          slv_reg35 <= slv_reg35;
                          slv_reg36 <= slv_reg36;
                          slv_reg37 <= slv_reg37;
                          slv_reg38 <= slv_reg38;
                          slv_reg39 <= slv_reg39;
                          slv_reg40 <= slv_reg40;
                          slv_reg41 <= slv_reg41;
                          slv_reg42 <= slv_reg42;
                          slv_reg43 <= slv_reg43;
                          slv_reg44 <= slv_reg44;
                          slv_reg45 <= slv_reg45;
                          slv_reg46 <= slv_reg46;
                          slv_reg47 <= slv_reg47;
                          slv_reg48 <= slv_reg48;
                          slv_reg49 <= slv_reg49;
                          slv_reg50 <= slv_reg50;
                          slv_reg51 <= slv_reg51;
                          slv_reg52 <= slv_reg52;
                          slv_reg53 <= slv_reg53;
                          slv_reg54 <= slv_reg54;
                          slv_reg55 <= slv_reg55;
                          slv_reg56 <= slv_reg56;
                          slv_reg57 <= slv_reg57;
                          slv_reg58 <= slv_reg58;
                          slv_reg59 <= slv_reg59;
                          slv_reg60 <= slv_reg60;
                          slv_reg61 <= slv_reg61;
                          slv_reg62 <= slv_reg62;
                          slv_reg63 <= slv_reg63;
                        end
            endcase
          end
      end
    end

    // Implement write response logic generation
    // The write response and response valid signals are asserted by the slave
    // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.
    // This marks the acceptance of address and indicates the status of
    // write transaction.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_bvalid  <= 0;
          axi_bresp   <= 2'b0;
        end
      else
        begin
          if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
            begin
              // indicates a valid write response is available
              axi_bvalid <= 1'b1;
              axi_bresp  <= 2'b0; // 'OKAY' response
            end                   // work error responses in future
          else
            begin
              if (S_AXI_BREADY && axi_bvalid)
                //check if bready is asserted while bvalid is high)
                //(there is a possibility that bready is always asserted high)
                begin
                  axi_bvalid <= 1'b0;
                end
            end
        end
    end

    // Implement axi_arready generation
    // axi_arready is asserted for one S_AXI_ACLK clock cycle when
    // S_AXI_ARVALID is asserted. axi_awready is
    // de-asserted when reset (active low) is asserted.
    // The read address is also latched when S_AXI_ARVALID is
    // asserted. axi_araddr is reset to zero on reset assertion.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_arready <= 1'b0;
          axi_araddr  <= 32'b0;
        end
      else
        begin
          if (~axi_arready && S_AXI_ARVALID)
            begin
              // indicates that the slave has acceped the valid read address
              axi_arready <= 1'b1;
              // Read address latching
              axi_araddr  <= S_AXI_ARADDR;
            end
          else
            begin
              axi_arready <= 1'b0;
            end
        end
    end

    // Implement axi_arvalid generation
    // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_ARVALID and axi_arready are asserted. The slave registers
    // data are available on the axi_rdata bus at this instance. The
    // assertion of axi_rvalid marks the validity of read data on the
    // bus and axi_rresp indicates the status of read transaction.axi_rvalid
    // is deasserted on reset (active low). axi_rresp and axi_rdata are
    // cleared to zero on reset (active low).
    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_rvalid <= 0;
          axi_rresp  <= 0;
        end
      else
        begin
          if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
            begin

              // Valid read data is available at the read data bus
              axi_rvalid <= 1'b1;
              axi_rresp  <= 2'b0; // 'OKAY' response
            end
          else if (axi_rvalid && S_AXI_RREADY)
            begin
              // Read data is accepted by the master
              axi_rvalid <= 1'b0;
            end
        end
    end

    // Implement memory mapped register select and read logic generation
    // Slave register read enable is asserted when valid address is available
    // and the slave is ready to accept the read address.
    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
    always @(*)
    begin
          // Address decoding for reading registers
          case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
            //BAR 1 addresses
            6'h00 : reg_data_out = {`DEV_MAGIC,`DEV_MAJOR, `DEV_MINOR}; // BAR1 access
            6'h01 : reg_data_out = {`DEV_NEXT_ADDR};
            6'h02 : reg_data_out = {`DEV_HW_ID,`DEV_HW_VENDOR};
            6'h03 : reg_data_out = {`DEV_FW_ID,`DEV_FW_VENDOR};
            6'h04 : reg_data_out = {`DEV_FW_MAJOR,`DEV_FW_MINOR,`DEV_FW_PATCH};
            6'h05 : reg_data_out = {`DEV_TSTAMP};
            6'h06 : reg_data_out = {`DEV_NAME1};
            6'h07 : reg_data_out = {`DEV_NAME2};
            6'h08 : reg_data_out = {`DEV_NAME3};
            6'h09 : reg_data_out = {`DEV_FULL_RST_CAPAB,`DEV_SOFT_RST_CAPAB,26'h0,`DEV_RTM_CAPAB,`DEV_ENDIAN_CAPAB}; // ro
            6'h0A : reg_data_out = {dev_full_rst_status,dev_soft_rst_status,28'h0,dev_rtm_status,dev_endian_status};    //SHAPI status
            6'h0B : reg_data_out = {dev_full_rst_control,dev_soft_rst_control,29'h0,dev_endian_control};                //SHAPI dev control

            6'h0F : reg_data_out = dev_scratch_reg;

            (`MOD_DMA_REG_OFF + 6'h00): reg_data_out <= #TCQ {`MOD_DMA_MAGIC,`MOD_DMA_MAJOR,`MOD_DMA_MINOR};
            (`MOD_DMA_REG_OFF + 6'h01): reg_data_out <= #TCQ {`MOD_DMA_NEXT_ADDR};
            (`MOD_DMA_REG_OFF + 6'h02): reg_data_out <= #TCQ {`MOD_DMA_FW_ID,`MOD_DMA_FW_VENDOR};
            (`MOD_DMA_REG_OFF + 6'h03): reg_data_out <= #TCQ {`MOD_DMA_FW_MAJOR,`MOD_DMA_FW_MINOR,`MOD_DMA_FW_PATCH};
            (`MOD_DMA_REG_OFF + 6'h04): reg_data_out <= #TCQ mod_name[31:0];
            (`MOD_DMA_REG_OFF + 6'h05): reg_data_out <= #TCQ mod_name[63:32];
            (`MOD_DMA_REG_OFF + 6'h06): reg_data_out <= #TCQ {`MOD_DMA_FULL_RST_CAPAB,`MOD_DMA_SOFT_RST_CAPAB,26'h0,`MOD_DMA_RTM_CAPAB,`MOD_DMA_MULTI_INT}; // Module Capabilities - ro

            (`MOD_DMA_REG_OFF + 6'h07): reg_data_out <= #TCQ {MOD_FULL_RST_STATUS,  MOD_SOFT_RST_STATUS, 30'h0};  // Module Status - ro
            (`MOD_DMA_REG_OFF + 6'h08): reg_data_out <= #TCQ {mod_full_rst_control, mod_soft_rst_control, 30'h0}; // Module Control rw
            (`MOD_DMA_REG_OFF + 6'h09): reg_data_out <= #TCQ `MOD_DMA_INTERRUPT_ID; // rw
            (`MOD_DMA_REG_OFF + 6'h0A): reg_data_out <= #TCQ  mod_interrupt_flag_clear_r; // rw
            (`MOD_DMA_REG_OFF + 6'h0B): reg_data_out <= #TCQ  mod_interrupt_mask_r; // rw
            (`MOD_DMA_REG_OFF + 6'h0C): reg_data_out <= #TCQ  MOD_INTERRUPT_FLAG; // ro
            (`MOD_DMA_REG_OFF + 6'h0D): reg_data_out <= #TCQ  MOD_INTERRUPT_ACTIVE; // ro
            // ....2
            (`MOD_DMA_REG_OFF + 6'h10): reg_data_out <= #TCQ status_reg; // ro
            (`MOD_DMA_REG_OFF + 6'h11): reg_data_out <= #TCQ control_r; // rw
/**
            (`MOD_DMA_REG_OFF + 6'h12): reg_data_out <= #TCQ chopp_period_r;// rw
//            (`MOD_DMA_REG_OFF + 6'h12): reg_data_out <= #TCQ {8'b0, dma_size_r}; // rw
            (`MOD_DMA_REG_OFF + 6'h13): reg_data_out <= #TCQ {`MOD_DMA_MAX_BYTES} ; // ro
            (`MOD_DMA_REG_OFF + 6'h14): reg_data_out <= #TCQ {`MOD_DMA_TLP_PAYLOAD}; // ro

            (`MOD_DMA_REG_OFF + 6'h30): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[17:0]); // rw
            (`MOD_DMA_REG_OFF + 6'h31): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[35:18]); // rw
            (`MOD_DMA_REG_OFF + 6'h32): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[53:36]); // rw
            (`MOD_DMA_REG_OFF + 6'h33): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[71:54]); // rw
            (`MOD_DMA_REG_OFF + 6'h34): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[89:72]); // rw
            (`MOD_DMA_REG_OFF + 6'h35): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[107:90]); // rw
            (`MOD_DMA_REG_OFF + 6'h36): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[125:108]); // rw
            (`MOD_DMA_REG_OFF + 6'h37): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[143:126]); // rw
            (`MOD_DMA_REG_OFF + 6'h38): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[161:144]); // rw
            (`MOD_DMA_REG_OFF + 6'h39): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[179:162]); // rw
            (`MOD_DMA_REG_OFF + 6'h3A): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[197:180]); // rw
            (`MOD_DMA_REG_OFF + 6'h3B): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[215:198]); // rw
            (`MOD_DMA_REG_OFF + 6'h3C): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[233:216]); // rw
            (`MOD_DMA_REG_OFF + 6'h3D): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[251:234]); // rw
            (`MOD_DMA_REG_OFF + 6'h3E): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[269:252]); // rw
            (`MOD_DMA_REG_OFF + 6'h3F): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[287:270]); // rw

            (`MOD_DMA_REG_OFF + 6'h40): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[305:288]); // rw
            (`MOD_DMA_REG_OFF + 6'h41): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[323:306]); // rw
            (`MOD_DMA_REG_OFF + 6'h42): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[341:324]); // rw
            (`MOD_DMA_REG_OFF + 6'h43): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[359:342]); // rw
            (`MOD_DMA_REG_OFF + 6'h44): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[377:360]); // rw
            (`MOD_DMA_REG_OFF + 6'h45): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[395:378]); // rw
            (`MOD_DMA_REG_OFF + 6'h46): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[413:396]); // rw
            (`MOD_DMA_REG_OFF + 6'h47): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[431:414]); // rw
            (`MOD_DMA_REG_OFF + 6'h48): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[449:432]); // rw
            (`MOD_DMA_REG_OFF + 6'h49): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[467:450]); // rw
            (`MOD_DMA_REG_OFF + 6'h4A): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[485:468]); // rw
            (`MOD_DMA_REG_OFF + 6'h4B): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[503:486]); // rw
            (`MOD_DMA_REG_OFF + 6'h4C): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[521:504]); // rw
            (`MOD_DMA_REG_OFF + 6'h4D): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[539:522]); // rw
            (`MOD_DMA_REG_OFF + 6'h4E): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[557:540]); // rw
            (`MOD_DMA_REG_OFF + 6'h4F): reg_data_out <= #TCQ adc18_extend_f(eo_offset_r[575:558]); // rw

            6'h80   : reg_data_out <= slv_reg128;
            6'h81   : reg_data_out <= slv_reg129;
            6'h82   : reg_data_out <= slv_reg130;
            6'h83   : reg_data_out <= slv_reg131;
            6'h84   : reg_data_out <= slv_reg132;
            6'h85   : reg_data_out <= slv_reg133;
            6'h86   : reg_data_out <= slv_reg134;
            6'h87   : reg_data_out <= slv_reg135;
            6'h88   : reg_data_out <= slv_reg136;
            6'h89   : reg_data_out <= slv_reg137;
            6'h8A   : reg_data_out <= slv_reg138;
            6'h8B   : reg_data_out <= slv_reg139;
            6'h8C   : reg_data_out <= slv_reg140;
            6'h8D   : reg_data_out <= slv_reg141;
            6'h8E   : reg_data_out <= slv_reg142;
            6'h8F   : reg_data_out <= slv_reg143;
            6'h90   : reg_data_out <= slv_reg144;
            6'h91   : reg_data_out <= slv_reg145;
            6'h92   : reg_data_out <= slv_reg146;
            6'h93   : reg_data_out <= slv_reg147;
            6'h94   : reg_data_out <= slv_reg148;
            6'h95   : reg_data_out <= slv_reg149;
            6'h96   : reg_data_out <= slv_reg150;
            6'h97   : reg_data_out <= slv_reg151;
            6'h98   : reg_data_out <= slv_reg152;
            6'h99   : reg_data_out <= slv_reg153;
            6'h9A   : reg_data_out <= slv_reg154;
            6'h9B   : reg_data_out <= slv_reg155;
            6'h9C   : reg_data_out <= slv_reg156;
            6'h9D   : reg_data_out <= slv_reg157;
            6'h9E   : reg_data_out <= slv_reg158;
            6'h9F   : reg_data_out <= slv_reg159;
            6'hA0   : reg_data_out <= slv_reg160;
            6'hA1   : reg_data_out <= slv_reg161;
            6'hA2   : reg_data_out <= slv_reg162;
            6'hA3   : reg_data_out <= slv_reg163;
            6'hA4   : reg_data_out <= slv_reg164;
            6'hA5   : reg_data_out <= slv_reg165;
            6'hA6   : reg_data_out <= slv_reg166;
            6'hA7   : reg_data_out <= slv_reg167;
            6'hA8   : reg_data_out <= slv_reg168;
            6'hA9   : reg_data_out <= slv_reg169;
            6'hAA   : reg_data_out <= slv_reg170;
            6'hAB   : reg_data_out <= slv_reg171;
            6'hAC   : reg_data_out <= slv_reg172;
            6'hAD   : reg_data_out <= slv_reg173;
            6'hAE   : reg_data_out <= slv_reg174;
            6'hAF   : reg_data_out <= slv_reg175;
            6'hB0   : reg_data_out <= slv_reg176;
            6'hB1   : reg_data_out <= slv_reg177;
            6'hB2   : reg_data_out <= slv_reg178;
            6'hB3   : reg_data_out <= slv_reg179;
            6'hB4   : reg_data_out <= slv_reg180;
            6'hB5   : reg_data_out <= slv_reg181;
            6'hB6   : reg_data_out <= slv_reg182;
            6'hB7   : reg_data_out <= slv_reg183;
            6'hB8   : reg_data_out <= slv_reg184;
            6'hB9   : reg_data_out <= slv_reg185;
            6'hBA   : reg_data_out <= slv_reg186;
            6'hBB   : reg_data_out <= slv_reg187;
            6'hBC   : reg_data_out <= slv_reg188;
            6'hBD   : reg_data_out <= slv_reg189;
            6'hBE   : reg_data_out <= slv_reg190;
            6'hBF   : reg_data_out <= slv_reg191;
            6'hC0   : reg_data_out <= slv_reg192;
            6'hC1   : reg_data_out <= slv_reg193;
            6'hC2   : reg_data_out <= slv_reg194;
            6'hC3   : reg_data_out <= slv_reg195;
            6'hC4   : reg_data_out <= slv_reg196;
            6'hC5   : reg_data_out <= slv_reg197;
            6'hC6   : reg_data_out <= slv_reg198;
            6'hC7   : reg_data_out <= slv_reg199;
*/
            default : reg_data_out <= 0;
          endcase
    end

    // Output register or memory read data
    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_rdata  <= 0;
        end
      else
        begin
          // When there is a valid read address (S_AXI_ARVALID) with
          // acceptance of read address by the slave (axi_arready),
          // output the read dada
          if (slv_reg_rden)
            begin
              axi_rdata <= reg_data_out;     // register read data
            end
        end
    end

    endmodule
