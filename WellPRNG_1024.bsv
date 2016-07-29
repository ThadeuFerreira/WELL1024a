package WellPRNG_1024;

import Vector::*;
import StmtFSM::*;

// My packages.
import RandomNumberGenerator::*;


//////// CONSTANT DEFINITION ///////////////////////////////
typedef  32     W;
typedef  32 	R;
typedef  0 	P;
typedef  3	M1;
typedef  24 	M2;
typedef  10 	M3;

// Standard w-bit word.
typedef Bit#(W) Int32WORD;

typedef Vector#(R, Int32WORD) WSTATE;


typedef struct {
	WSTATE state;
	Bit#(32) state_i;
	Bit#(32) z0;
	Bit#(32) z1;
	Bit#(32) z2;
	Int32WORD newV0;
	Int32WORD newV1;
} GlobalPram;

function Int32WORD mat0pos(Int32WORD t, Int32WORD v);
	Int32WORD ret = v^(v>>t);
	return ret;
endfunction: mat0pos

function Int32WORD mat0neg(Int32WORD t, Int32WORD v);
	Int32WORD ret = v^(v<<(-t));
	return ret;
endfunction: mat0neg

function Int32WORD mat3neg(Int32WORD t, Int32WORD v);
	Int32WORD ret = (v<<(-(t)));
	return ret;
endfunction: mat3neg

function Int32WORD mat4neg(Int32WORD t, Bit#(32) b, Int32WORD v);
	Int32WORD ret = v ^ ((v<<(-t)) & b);
	return ret;
endfunction: mat4neg



function GlobalPram  wellRNG1024a(WSTATE state, Int32WORD state_i, Int32WORD  z0, Int32WORD  z1, Int32WORD z2, Int32WORD newV0, Int32WORD newV1);
	GlobalPram ret;
	  z0    = state[(state_i+31) & 'h0000001f];
	  z1    = state[state_i]       ^ mat0pos (8, state[(state_i+3) & 'h0000001f]);
	  z2    = mat0neg (-19,  state[(state_i+24) & 'h0000001f]) ^ mat0neg(-14, state[(state_i+10) & 'h0000001f]);
	  state[state_i] = z1                 ^ z2; 
	  state[(state_i+31)&'h0000001f] = mat0neg (-11,z0)   ^ mat0neg(-7,z1)    ^ mat0neg(-13,z2) ;
	  state_i = (state_i + 31) & 'h0000001f;
	
	ret.z0 = z0;
	ret.z1 = z1;
	ret.z2 = z2;
	ret.state = state;
	ret.state_i = state_i;	
	ret.newV0 = newV0;
	ret.newV1 = newV1;
	ret.state = state;
	return ret;
endfunction: wellRNG1024a


(* synthesize *)
module mkWellPRNG_1024 (IfcRandomNumberGenerator#(Int32WORD, Int32WORD));

   Reg#(Bit#(32)) state_i <- mkRegU;
   Reg#(Bit#(32)) z0 <- mkRegU;
   Reg#(Bit#(32)) z1 <- mkRegU;
   Reg#(Bit#(32)) z2 <- mkRegU;
   Reg#(Bit#(32)) newV0 <- mkRegU;
   Reg#(Bit#(32)) newV1 <- mkRegU;

   //Reg#(WSTATE) state <- mkReg (replicate(0));
   Vector#(R,Reg#(Bit#(32))) state <- replicateM( mkRegU );

   method Action initialize (Int32WORD  s);
	state[0] <=      s + 72852922;
	state[1] <=      s + 41699578;
	state[2] <=      s + 56707026;
	state[3] <=      33717249;
	state[4] <=      18306974;
	state[5] <=      30824004;
	state[6] <=      42901955;
	state[7] <=      80465302;
	state[8] <=      94968136;
	state[9] <=      41480876;
	state[10] <=      57870066;
	state[11] <=      37220400;
	state[12] <=      14597146;
	state[13] <=      1165159;
	state[14] <=      99349121;
	state[15] <=      68083911;	
	state[16] <=      s + 72852922;
	state[17] <=      s + 4169978;
	state[18] <=      s + 5670026;
	state[19] <=      717249;
	state[20] <=      306974;
	state[21] <=      824004;
	state[22] <=      901955;
	state[23] <=      0465302;
	state[24] <=      4968136;
	state[25] <=      480876;
	state[26] <=      7870066;
	state[27] <=      7220400;
	state[28] <=      14597146;
	state[29] <=      1165159;
	state[30] <=      99349121;
	state[31] <=      83911;
   endmethod: initialize

   method ActionValue#(Int32WORD ) get () ;

	WSTATE mystate = readVReg(state);
	//$display("! %d %d %d %d %d %d", state[state_i], state_i, z0, z1, z2, newV0);
        
	GlobalPram param = wellRNG1024a( mystate,  state_i,  z0,   z1,  z2, newV0, newV1);

	z0 <= param.z0;
	z1 <= param.z1;
	z2 <= param.z2;
	state_i <= param.state_i;
	newV0 <= param.newV0;	
	newV1 <= param.newV1;
	writeVReg(state, param.state);

	return state[state_i];
   endmethod: get

endmodule: mkWellPRNG_1024

endpackage: WellPRNG_1024
