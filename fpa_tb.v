`timescale 1ns/100ps
module fpa_tb();

    reg ram_addr;
    wire ram_out, done;

    fpa fpa(.ram_addr(ram_addr), .ram_out(ram_out), .done(done));
    initial begin
    
        //se for usar o gtkwave
        $dumpfile("Nome_Arquivo_tb.vcd");
        $dumpvars(0, Nome_Arquivo_tb);
        //

        ram_addr = 3'bz; 
        $finish;
    end
endmodule