//
// Micro uart-1 APB wrapper
//
// Provides APB interface for micro UART 1
//
//
// Freeware 2015, Fen Logic Ltd.
// This code is free and is delivered 'as is'.
// It comes without any warranty, to the extent permitted by applicable law.
// There are no restrictions to any use or re-use of this code
// in any form or shape. It would be nice if you keep my company name
// in the source or modified source code but even that is not
// required as I can't check it anyway.
// But the code comes with no warranties or guarantees whatsoever.
//

module micro_uart3_apb
(
   input             clk,            // system clock also used for baudrate
   input             reset_n,        // active low reset  
   input             ref_clock,      // System unchanging timing clock 
                                     // must be slower then clk/2
   
   // APB interface
   input          apb_psel,     // active high if UART is selected
   input          apb_penable,  // active high if UART is selected
   input          apb_pwrite,   // active high if writing
   input  [ 31:0] apb_pwdata,   // APB write data
   input  [  3:0] apb_paddr,    // APB address bus LS 2 bits are unused
   output [ 31:0] apb_prdata,   // data read back
   output         apb_pready,
   output         apb_pslverr,
   output         irq,          // interrupt
  
   input          ser_in,         // Micro uart serial input
   output         ser_out         // Micro uart serial output
);


   // CPU bus
wire        data_select;  // High when cpu read/writes data reg.
wire        baud_select;  // High when cpu read/writes baud reg.
wire        cpu_read;       // High when cpu does read
wire        cpu_write;      // High when cpu does write
wire [15:0] cpu_wdata;      // Data written by cpu
wire [15:0] cpu_rdata;      // Data back to cpu,

micro_uart3
micro_uart3_inst (
      .clk          (clk),
      .reset_n      (reset_n),
      .ref_clock    (ref_clock),

   // CPU bus
      .data_select(data_select),
      .baud_select(baud_select),
      .cpu_read     (cpu_read),
      .cpu_write    (cpu_write),
      .cpu_wdata    (cpu_wdata),
      .cpu_rdata    (cpu_rdata),
      .irq          (irq),

   // UART port
      .ser_in       (ser_in),
      .ser_out      (ser_out)
   );

   assign data_select = (apb_paddr[3:2]==2'h0);
   assign baud_select = (apb_paddr[3:2]==2'h1);
   assign cpu_read      = apb_psel & apb_penable & ~apb_pwrite;
   assign cpu_write     = apb_psel & apb_penable &  apb_pwrite;

   assign cpu_wdata  = apb_pwdata[15:0];
   assign apb_prdata = {16'h0,cpu_rdata};

   assign apb_pready  = 1'b1;
   assign apb_pslverr = 1'b0;

endmodule



