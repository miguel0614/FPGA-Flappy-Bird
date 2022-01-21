// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1.1 (win64) Build 3286242 Wed Jul 28 13:10:47 MDT 2021
// Date        : Fri Nov 12 13:45:11 2021
// Host        : Miguel-ControlTower running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {c:/Users/Miguel/OneDrive/Courses/ee478/Final Project PMods/Final
//               Project.gen/sources_1/ip/clk_gen_2/clk_gen_2_stub.v}
// Design      : clk_gen_2
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_gen_2(clk_out1, reset, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,reset,locked,clk_in1" */;
  output clk_out1;
  input reset;
  output locked;
  input clk_in1;
endmodule
