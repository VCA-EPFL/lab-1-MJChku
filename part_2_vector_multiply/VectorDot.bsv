import Vector::*;
import BRAM::*;

// Time spent on VectorDot: ____

// Please annotate the bugs you find.

interface VD;
    method Action start(Bit#(8) dim_in, Bit#(2) i);
    method ActionValue#(Bit#(32)) response();
endinterface

(* synthesize *)
module mkVectorDot (VD);
    BRAM_Configure cfg1 = defaultValue;
    cfg1.loadFormat = tagged Hex "v1.hex";
    BRAM1Port#(Bit#(8), Bit#(32)) a <- mkBRAM1Server(cfg1);
    BRAM_Configure cfg2 = defaultValue;
    cfg2.loadFormat = tagged Hex "v2.hex";
    BRAM1Port#(Bit#(8), Bit#(32)) b <- mkBRAM1Server(cfg2);

    Reg#(Bit#(32)) output_res <- mkReg(unpack(0));

    Reg#(Bit#(8)) dim <- mkReg(0);

    Reg#(Bool) ready_start <- mkReg(False);
    Reg#(Bit#(8)) pos_a <- mkReg(unpack(0));
    Reg#(Bit#(8)) pos_b <- mkReg(unpack(0));
    Reg#(Bit#(8)) pos_out <- mkReg(unpack(0));
    Reg#(Bool) done_all <- mkReg(False);
    Reg#(Bool) done_a <- mkReg(False);
    Reg#(Bool) done_b <- mkReg(False);
    Reg#(Bool) req_a_ready <- mkReg(False);
    Reg#(Bool) req_b_ready <- mkReg(False);

    // error: not enough bits
    Reg#(Bit#(3)) i <- mkReg(0);


    rule process_a (ready_start && !done_a && !req_a_ready);
        // $display("firing a with idx %d pos %d max %d", i, pos_a, dim*zeroExtend(i+1));
        a.portA.request.put(BRAMRequest{write: False, // False for read
                            responseOnWrite: False,
                            address: zeroExtend(pos_a),
                            datain: ?});
        // error : pos_a end with dim*zeroExtend(i+1)
        if (pos_a < dim*zeroExtend(i+1))
            pos_a <= pos_a + 1;
        else done_a <= True;

        req_a_ready <= True;

    endrule

    rule process_b (ready_start && !done_b && !req_b_ready);
        // $display("firing b with idx %d pos %d", i, pos_b);
        b.portA.request.put(BRAMRequest{write: False, // False for read
                responseOnWrite: False,
                address: zeroExtend(pos_b),
                datain: ?});
        // error : pos_b end with dim*zeroExtend(i+1)
        if (pos_b < dim*zeroExtend(i+1))
            pos_b <= pos_b + 1;
        else done_b <= True;
    
        req_b_ready <= True;
    endrule

    rule mult_inputs (req_a_ready && req_b_ready && !done_all);
        // $display("mult %d pos %d", output_res, pos_out);
        let out_a <- a.portA.response.get();
        let out_b <- b.portA.response.get();

        // error: should accumulate
        output_res <=  output_res + out_a*out_b;     
        pos_out <= pos_out + 1;
        
        if (pos_out == dim-1) begin
            done_all <= True;
            // error reset ready_start
            ready_start <= False;
        end


        req_a_ready <= False;
        req_b_ready <= False;
    endrule

    // rule alwaysfire;
    //     $display("pos_out %d dim %d done_all %d done_a %d", pos_out, dim, done_all, done_a);
    // endrule

    method Action start(Bit#(8) dim_in, Bit#(2) i_in) if (!ready_start);
        // $display("start dim_in*i_in %d", dim_in*zeroExtend(i_in));
        ready_start <= True;
        dim <= dim_in;
        done_all <= False;
        // error : should be i_in
        pos_a <= dim_in*zeroExtend(i_in);
        pos_b <= dim_in*zeroExtend(i_in);
        done_a <= False;
        done_b <= False;
        pos_out <= 0;
        i <= zeroExtend(i_in);
        //error should reset output_res
        output_res <= 0;
    endmethod

    method ActionValue#(Bit#(32)) response() if (done_all);
        // $display("resp");
        return output_res;
    endmethod

endmodule


