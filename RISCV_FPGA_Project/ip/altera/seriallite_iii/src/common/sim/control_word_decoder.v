module control_word_decoder
(
   input                      clock,
   input                      reset,

   input                      valid,
   input       [63:0]         word,
   input                      ctrl_flag,

   output reg  [255:0]        decoded_word_string
);

   always @(*) begin

      if (reset == 1'b1) begin

         decoded_word_string = "Reset";

      end else if (valid == 1'b0) begin

         decoded_word_string = "Invalid";

      end else if (ctrl_flag == 1'b0) begin

         decoded_word_string = "Data";

      end else if ((word[63]    == 1'b1) &&     // Burst Control Word flag
                   (word[62]    == 1'b1) &&     // Burst Control Word valid flag
                   (word[61]    == 1'b1) &&     // SOP
                   (word[60:57] == 4'b0000)     // EOP
                  ) begin

         decoded_word_string = "Bc:SOP";

      end else if ((word[63]    == 1'b1) &&     // Burst Control Word flag
                   (word[62]    == 1'b1) &&     // Burst Control Word valid flag
                   (word[61]    == 1'b0) &&     // SOP
                   (word[60:57] == 4'b1000)     // EOP
                  ) begin

         decoded_word_string = "Bc:EOP";

      end else if ((word[63]    == 1'b1) &&     // Burst Control Word flag
                   (word[62]    == 1'b1) &&     // Burst Control Word valid flag
                   (word[61]    == 1'b0) &&     // SOP
                   (word[60:57] == 4'b0000) &&  // EOP
                   (word[27]    == 1'b0)        // User inserted idle flag
                  ) begin

         decoded_word_string = "Bc:Idle";

      end else if ((word[63]    == 1'b1) &&     // Burst Control Word flag
                   (word[62]    == 1'b1) &&     // Burst Control Word valid flag
                   (word[61]    == 1'b0) &&     // SOP
                   (word[60:57] == 4'b0000) &&  // EOP
                   (word[27]    == 1'b1)        // User inserted idle flag
                  ) begin

         decoded_word_string = "Bc:UserIdle";

      end else if (word[63:58] == 6'b011110) begin

         decoded_word_string = "Mf:Sy";

      end else if (word[63:58] == 6'b001010) begin

         decoded_word_string = "Mf:Ss";

      end else if (word[63:58] == 6'b000111) begin

         decoded_word_string = "Mf:Sk";

      end else if (word[63:58] == 6'b011001) begin

         decoded_word_string = "Mf:Di";

      end else begin

         decoded_word_string = "Error:Unknown";

      end

   end

endmodule
