// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



`ifdef INCLUDED_SMPTE352M
`else
`define INCLUDED_SMPTE352M

  `define C_PICTURE_RATE_NA         4'b0000
  `define C_PICTURE_RATE_23         4'b0010
  `define C_PICTURE_RATE_24         4'b0011
  `define C_PICTURE_RATE_25         4'b0101
  `define C_PICTURE_RATE_29         4'b0110
  `define C_PICTURE_RATE_30         4'b0111
  `define C_PICTURE_RATE_50         4'b1001
  `define C_PICTURE_RATE_59         4'b1010
  `define C_PICTURE_RATE_60         4'b1011

  `define C_INTERFACE_NA            4'b0000
  `define C_INTERFACE_SD_270        4'b0001
  `define C_INTERFACE_IPT           4'b0010 // Used For Proprietary Formats.
  `define C_INTERFACE_SD_540        4'b0011
  `define C_INTERFACE_720_1G5       4'b0100
  `define C_INTERFACE_1080_1G5      4'b0101
  `define C_INTERFACE_SD_1G5        4'b0110
  `define C_INTERFACE_1080_1G5_DL   4'b0111
  `define C_INTERFACE_720_3G        4'b1000
  `define C_INTERFACE_1080_3G       4'b1001
  `define C_INTERFACE_DL_3G         4'b1010 // Dual Link
  `define C_INTERFACE_720_3G_DS     4'b1011 // Dual Streams
  `define C_INTERFACE_1080_3G_DS    4'b1100 // Dual Streams
  `define C_INTERFACE_SD_3G_DS      4'b1101 // Dual Streams

  `define C_INTERLACE               1'b0
  `define C_PROGRESSIVE             1'b1

  `define C_ASPECT_4_3              1'b0
  `define C_ASPECT_16_9             1'b1

  `define C_STRUCTURE_422_YUV       4'b0000
  `define C_STRUCTURE_444_YUV       4'b0001
  `define C_STRUCTURE_444_RGB       4'b0010
  `define C_STRUCTURE_420           4'b0011
  `define C_STRUCTURE_4224_YUVA     4'b0100
  `define C_STRUCTURE_4444_YUVA     4'b0101
  `define C_STRUCTURE_4444_RGBA     4'b0110
  `define C_STRUCTURE_4224_YUVD     4'b1000
  `define C_STRUCTURE_4444_YUVD     4'b1001
  `define C_STRUCTURE_4444_RGBD     4'b1010

  `define C_CHANNEL_1               2'b00
  `define C_CHANNEL_2               2'b01
  `define C_CHANNEL_3               2'b10
  `define C_CHANNEL_4               2'b11

  `define C_BIT_DEPTH_8             2'b00
  `define C_BIT_DEPTH_10            2'b01
  `define C_BIT_DEPTH_12            2'b10

  // Special Video Standards Definition
  `define C_STD_NONE                {4'b1000,`C_INTERFACE_NA       ,1'b0         ,1'b0          ,2'b00,`C_PICTURE_RATE_NA,`C_ASPECT_4_3  ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_8}
  `define C_STD_UNKNOWN             {4'b1000,`C_INTERFACE_NA       ,1'b0         ,1'b0          ,2'b00,`C_PICTURE_RATE_NA,`C_ASPECT_4_3  ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_8}
  `define C_STD_TEST_SD             {4'b1000,`C_INTERFACE_SD_270   ,1'b0         ,`C_INTERLACE  ,2'b00,`C_PICTURE_RATE_NA,`C_ASPECT_4_3  ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_8}
  `define C_STD_TEST_HD             {4'b1000,`C_INTERFACE_1080_1G5 ,`C_INTERLACE ,`C_INTERLACE  ,2'b00,`C_PICTURE_RATE_NA,`C_ASPECT_16_9 ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}

  // Common Video Standards Definition
  `define C_STD_486I59              {4'b1000,`C_INTERFACE_SD_270   ,1'b0         ,`C_INTERLACE  ,2'b00,`C_PICTURE_RATE_29,`C_ASPECT_4_3 ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_576I50              {4'b1000,`C_INTERFACE_SD_270   ,1'b0         ,`C_INTERLACE  ,2'b00,`C_PICTURE_RATE_25,`C_ASPECT_4_3 ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_720P60              {4'b1000,`C_INTERFACE_720_1G5  ,1'b0         ,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_60,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_720P59              {4'b1000,`C_INTERFACE_720_1G5  ,1'b0         ,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_59,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_720P50              {4'b1000,`C_INTERFACE_720_1G5  ,1'b0         ,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_50,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_720P30              {4'b1000,`C_INTERFACE_720_1G5  ,1'b0         ,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_30,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_720P29              {4'b1000,`C_INTERFACE_720_1G5  ,1'b0         ,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_29,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_720P25              {4'b1000,`C_INTERFACE_720_1G5  ,1'b0         ,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_25,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_720P24              {4'b1000,`C_INTERFACE_720_1G5  ,1'b0         ,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_24,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_720P23              {4'b1000,`C_INTERFACE_720_1G5  ,1'b0         ,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_23,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_1080I60             {4'b1000,`C_INTERFACE_1080_1G5,`C_INTERLACE  ,`C_INTERLACE  ,2'b00,`C_PICTURE_RATE_30,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_1080I59             {4'b1000,`C_INTERFACE_1080_1G5,`C_INTERLACE  ,`C_INTERLACE  ,2'b00,`C_PICTURE_RATE_29,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_1080I50             {4'b1000,`C_INTERFACE_1080_1G5,`C_INTERLACE  ,`C_INTERLACE  ,2'b00,`C_PICTURE_RATE_25,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_1080SF24            {4'b1000,`C_INTERFACE_1080_1G5,`C_INTERLACE  ,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_24,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_1080SF23            {4'b1000,`C_INTERFACE_1080_1G5,`C_INTERLACE  ,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_23,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_1080P30             {4'b1000,`C_INTERFACE_1080_1G5,`C_PROGRESSIVE,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_30,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_1080P29             {4'b1000,`C_INTERFACE_1080_1G5,`C_PROGRESSIVE,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_29,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_1080P25             {4'b1000,`C_INTERFACE_1080_1G5,`C_PROGRESSIVE,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_25,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_1080P24             {4'b1000,`C_INTERFACE_1080_1G5,`C_PROGRESSIVE,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_24,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_1080P23             {4'b1000,`C_INTERFACE_1080_1G5,`C_PROGRESSIVE,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_23,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}

  // SMPTE425-A Mapping Structure 1
  `define C_STD_3GA_1080P60         {4'b1000,`C_INTERFACE_1080_3G ,`C_PROGRESSIVE,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_60,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_3GA_1080P59         {4'b1000,`C_INTERFACE_1080_3G ,`C_PROGRESSIVE,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_59,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}
  `define C_STD_3GA_1080P50         {4'b1000,`C_INTERFACE_1080_3G ,`C_PROGRESSIVE,`C_PROGRESSIVE,2'b00,`C_PICTURE_RATE_50,1'b0          ,3'b000,`C_STRUCTURE_422_YUV,`C_CHANNEL_1,4'b0000,`C_BIT_DEPTH_10}

`endif
