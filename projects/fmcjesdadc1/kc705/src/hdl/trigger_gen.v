`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/30/2018 03:15:44 PM
// Design Name:
// Module Name: trigger_gen
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Additional Comments:
//
//
// Copyright 2018 IPFN-Instituto Superior Tecnico, Portugal
// Creation Date   04/30/2018 03:15:44 PM
//
// Licensed under the EUPL, Version 1.2 or - as soon they
// will be approved by the European Commission - subsequent
// versions of the EUPL (the "Licence");
//
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
module trigger_gen #(
  parameter     ADC_DATA_WIDTH = 16)  // ADC is 14 bit, but data is 16
  (
    input clk,      // 125 Mhz , two samples per clock
    input [31:0] adc_data_a,
    input adc_enable_a,
    input adc_valid_a,
    input [31:0] adc_data_b,
    input adc_enable_b,
    input adc_valid_b,
    input [31:0] adc_data_c,
    input adc_enable_c,
    input adc_valid_c,
    input [31:0] adc_data_d,
    input adc_enable_d,
    input adc_valid_d,

    input trig_enable,  // Enable/Reset State Machine
    input  [31:0] trig_level_a, //
    input  [31:0] trig_level_b, //
    input  [31:0] trig_level_c, //

    input      [31:0]  param_mul,
    input      [31:0]  param_off,

    output [31:0] pulse_tof,  // Difference Pulse_0 -> Pulse_1
    output detect_pls_0, //channel 4 Osc
    output detect_pls_1
  );
/*********** Function Declarations ***************/

function signed [ADC_DATA_WIDTH:0] adc_channel_sum_f;  // 17 bit for sum headroom
	 input [31:0] adc_data;

     reg signed [ADC_DATA_WIDTH:0] adc_ext_1st;
     reg signed [ADC_DATA_WIDTH:0] adc_ext_2nd;
	   begin
            adc_ext_1st = $signed({adc_data[15],  adc_data[15:0]}); // sign extend
            adc_ext_2nd = $signed({adc_data[31], adc_data[31:16]});
            adc_channel_sum_f = adc_ext_1st + adc_ext_2nd;
	  end
  endfunction

function  trigger_rising_eval_f;
	input signed [ADC_DATA_WIDTH:0] adc_channel_mean;
	input signed [ADC_DATA_WIDTH-1:0] trig_lvl;

    reg signed [ADC_DATA_WIDTH:0] trig_lvl_ext;
	begin
       trig_lvl_ext          = $signed({trig_lvl, 1'b0}); // Mult * 2 with sign
       trigger_rising_eval_f =(adc_channel_mean > trig_lvl_ext)? 1'b1: 1'b0;
    end
endfunction

/*
https://web.mit.edu/6.111/www/f2016/handouts/L08_4.pdf
wire signed [31:0] a,b,s;
wire z,n,v,c;
assign {c,s} = a + b;
assign z = ~|s;
assign n = s[31];
assign v = a[31]^b[31]^s[31]^c; /overload
*/
/*
function  trigger_falling_eval_f;
	input signed [ADC_DATA_WIDTH:0] adc_channel_mean;
	input signed [ADC_DATA_WIDTH-1:0] trig_lvl;
	reg signed [ADC_DATA_WIDTH:0] trig_lvl_ext;
    reg signed [ADC_DATA_WIDTH-1:0] s;
	reg z,n,v,c;
	begin
	    trig_lvl_ext = $signed({trig_lvl, 1'b0}); // Mult * 2  with  sign extend
	    {c,s} = adc_channel_mean + trig_lvl_ext;
	    trigger_falling_eval_f = s[31]; // negative if adc_channel_mean
        //trig_lvl_ext = $signed({trig_lvl, 1'b0}); // Mult * 2  with  sign extend
        // trigger_falling_eval_f =(adc_channel_mean < trig_lvl_ext)? 1'b1: 1'b0;
    end
endfunction
*/

function  trigger_falling_eval_f;
	input signed [ADC_DATA_WIDTH:0] adc_channel_mean;
	input signed [ADC_DATA_WIDTH-1:0] trig_lvl;
	reg signed [ADC_DATA_WIDTH:0] trig_lvl_ext;
	reg less;
	begin
        trig_lvl_ext = $signed({trig_lvl, 1'b0}); // Mult * 2  with  sign extend
        less = adc_channel_mean < trig_lvl_ext;
        trigger_falling_eval_f =(less)? 1'b1: 1'b0;
    end
endfunction


/*
localparam delay=100;
function timing_calculation;
     input [31:0] timer1;
     input [31:0] timer2;
     input [31:0] count;

       reg [31:0] avg_time;
       begin
         avg_time=(timer1+timer2)>>1;

         timing_calculation=((avg_time-delay) >= count)?1'b1:1'b0;
     end

 endfunction
*/
/*********** End Function Declarations ***************/

/************ Trigger Logic ************/
	/* ADC Data comes in pairs. Compute mean, or simply add */
	(* mark_debug = "true" *) reg signed [ADC_DATA_WIDTH:0] adc_sum_a, adc_sum_b, adc_sum_c, adc_sum_d ;
	always @(posedge clk) begin
         if (adc_enable_a)  // Use adc_valid_a ?
            adc_sum_a <= adc_channel_sum_f(adc_data_a); // check order (not really necessary, its a mean...)
         if (adc_enable_b)  // Use adc_valid_b ?
            adc_sum_b <= adc_channel_sum_f(adc_data_b);
         if (adc_enable_c)
            adc_sum_c <= adc_channel_sum_f(adc_data_c);
         if (adc_enable_d)
            adc_sum_d <= adc_channel_sum_f(adc_data_d);
	end

	reg  detect_pls_0_r;
    assign detect_pls_0 = detect_pls_0_r;

	reg  detect_pls_1_r = 0;
    assign detect_pls_1 = detect_pls_1_r;
/*
    reg  signed [15:0]  trig_level_a_reg=0;
    reg  signed [15:0]  trig_level_b_reg=0;
    reg  signed [15:0]  trig_level_c_reg=0;
 */
    (* mark_debug = "true" *) wire  signed [15:0]  trig_level_a_p = trig_level_a[31:16];
    (* mark_debug = "true" *) wire  signed [15:0]  trig_level_a_m = trig_level_a[15:0];
    (* mark_debug = "true" *) wire  signed [15:0]  trig_level_b_p = trig_level_b[31:16];
    (* mark_debug = "true" *) wire  signed [15:0]  trig_level_b_m = trig_level_b[15:0];
    (* mark_debug = "true" *) wire  signed [15:0]  trig_level_c_p = trig_level_c[31:16];
    (* mark_debug = "true" *) wire  signed [15:0]  trig_level_c_m = trig_level_c[15:0];

     (* mark_debug = "true" *) wire less_i = trigger_falling_eval_f(adc_sum_b, trig_level_b_m);
     
     reg [31:0] pulse_delay_r =  32'hFFFF;
     assign pulse_tof = pulse_delay_r;

	 localparam IDLE    = 3'b000;
     localparam READY   = 3'b001;
     localparam PULSE0  = 3'b010;
     localparam PULSE1  = 3'b011;
     localparam PULSE2  = 3'b100;
     localparam TRIGGER = 3'b101;

     //localparam WAIT_WIDTH = 24;

     reg signed [31:0] wait_cnt = 0; // {WAIT_WIDTH{1'b1}}

     (* mark_debug = "true" *)  reg [2:0] state = IDLE;

    //reg [31:0] wait_cnt2=0,counter=0;
    reg signed [31:0] counter=0;

 always @(posedge clk)
       if (!trig_enable) begin
          state <= IDLE;
          detect_pls_0_r  <=  0;
          detect_pls_1_r  <=  0;
          wait_cnt    <= 32'd125_000_000; ////* 8ns Initial Idle Time  = 1 ms , Max 16777215 134 ms
//          pulse_delay_r  <=  32'hFFFF;

       end
       else
          case (state)
             IDLE: begin        // Sleeping
                detect_pls_0_r  <=  0;
                detect_pls_1_r  <=  0;
                wait_cnt <= wait_cnt - 1;
                 if (wait_cnt == {32{1'b0}}) begin
                   state <= READY;
                   //pulse_delay_r  <=   32'h0A; // Testing
                 end
             end
             READY: begin // Armed: Waiting first pulse
                if (trigger_rising_eval_f(adc_sum_a, trig_level_a_p)) begin
                   state <= PULSE0;
                   detect_pls_0_r  <=  1'b1;
                   pulse_delay_r  <=   {trig_level_b_m, 16'h0B} ; // Testing
                   wait_cnt <= 0;
                end
    //            detect_pls_0_r  <=  0;
             end
             PULSE0 : begin // Got first pulse. Waiting Second  8ns = 0.08 mm @ 10000m/s

                if (trigger_falling_eval_f(adc_sum_b, trig_level_b_m)) begin // Testing  negative edge of input b
                    state <= PULSE1;
                      pulse_delay_r  <=  wait_cnt + $signed(param_off);  // Save waiting Time + Offset
                      wait_cnt       <=  wait_cnt + $signed(param_off);  // Save pulse B-A  Time + Offset
                    //pulse_delay_r  <=  {trig_level_b_m, wait_cnt[31:15]};  //  testing
                    detect_pls_0_r  <=  1'b0;
                end
                else
                    wait_cnt   <=  wait_cnt + $signed(param_mul);           //  time units
             end
             PULSE1 : begin   // Waiting Third Pulse
                if (trigger_rising_eval_f(adc_sum_c, trig_level_c_p)) begin
                    detect_pls_1_r  <=  1'b1;
                    state       <= PULSE2;
                    counter     <= 32'h00;
                end

             end
             PULSE2 : begin   // Got Third pulse. Waiting calculated delay
                if (counter >= wait_cnt) begin
                   detect_pls_1_r <=  1'b0;
                   state        <= TRIGGER;
                end
                else begin
                    counter <= counter + 32'h0001_0000;  // count 8ns periods 
                    end
             end
             TRIGGER : begin // End Trigger
                detect_pls_0_r <=  1'b1;
 //                    state <= IDLE;
             end
             default :
                     state <= IDLE;
          endcase


endmodule
