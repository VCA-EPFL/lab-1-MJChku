import Vector::*;

typedef Bit#(16) Word;

function Vector#(16, Word) naiveShfl(Vector#(16, Word) in, Bit#(4) shftAmnt);
    Vector#(16, Word) resultVector = in; 
    for (Integer i = 0; i < 16; i = i + 1) begin
        Bit#(4) idx = fromInteger(i);
        resultVector[i] = in[shftAmnt+idx];
    end
    return resultVector;
endfunction


function Vector#(16, Word) barrelLeft(Vector#(16, Word) in, Bit#(4) shftAmnt);
    Vector#(16, Word) resultVector = newVector();
    Bit#(5) max = 16; 
    Bit#(5) wrapAmnt = max-{0, shftAmnt};
    Vector#(16, Word) result = naiveShfl(in, shftAmnt);
    for(Integer i = 0; i < 16; i = i + 1) begin
        if( fromInteger(i) >= wrapAmnt)
            result[i] = in[fromInteger(i)-wrapAmnt];
    end
    return result;
    // Implementation of a left barrel shifter
endfunction
