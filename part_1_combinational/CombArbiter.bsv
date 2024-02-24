import Vector::*;

typedef struct {
 Bool valid;
 Bit#(31) data;
 Bit#(4) index;
} ResultArbiter deriving (Eq, FShow);

function ResultArbiter arbitrateTree(Vector#(16, Bit#(1)) ready, Vector#(16, Bit#(31)) data, Integer _start, Integer _end);
    if(_start == _end) begin
        return ResultArbiter{valid: ready[_start]==1, data: data[_start], index: fromInteger(_start)};
    end
	else begin
        Integer mid = (_start + _end) / 2;
        ResultArbiter left = arbitrateTree(ready, data, _start, mid);
        ResultArbiter right = arbitrateTree(ready, data, mid+1, _end);
		if(left.valid) return left;
    	else return right;
    end
endfunction

function ResultArbiter arbitrate(Vector#(16, Bit#(1)) ready, Vector#(16, Bit#(31)) data);
    return arbitrateTree(ready, data, 0, 15);
endfunction
