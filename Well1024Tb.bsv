
package Well1024Tb;



// Bluespec standard packages.
import StmtFSM::*;

// My packages.
import RandomNumberGenerator::*;
import WellPRNG_1024::*;



// Expoents for the number of outputs to be generated (2^N).
typedef 28 N_DEFAULT;      // For fast human conference.
typedef 31 N_SMALL_CRUSH;  // TestU01 Small Crush Battery. Empirically determined.
typedef 41 N_CRUSH;        // TestU01 Crush Battery. TestU01 user guide fails! Empirically determined.
typedef 62 N_BIG_CRUSH;    // TestU01 Big Crush Battery. TestU01 user guide fails!
typedef 34 N_DIEHARD;      // Marsaglia's DIEHARD. Empirically determined.
typedef 10 N_NIST;         // NIST test. Empirically determined.



(* synthesize *)
module mkWell1024Tb (Empty);
   
   
   IfcRandomNumberGenerator#(Int32WORD, Int32WORD) rng <- mkWellPRNG_1024  ();
   
   
   // Expoent of the number of outputs to be generated (2^N).
   Reg#(UInt#(32)) n <- mkReg (fromInteger (valueOf (N_DEFAULT)));
   
   // Output counter.
   Reg#(UInt#(64)) i <- mkReg (0);
   
   
   Stmt verify_stmt =
   seq
      
      // Get TestU01 test type and set N.
      action
	 
	 let small_crush <- $test$plusargs ("SmallCrush");
	 let crush       <- $test$plusargs ("Crush");
	 let big_crush   <- $test$plusargs ("BigCrush");
 	 let diehard     <- $test$plusargs ("DIEHARD");
	 let nist        <- $test$plusargs ("NIST");
	 
	 // Priority: Small Crush > Crush > Big Crush > DIEHARD > NIST.
	 if      (small_crush) n <= fromInteger (valueOf (N_SMALL_CRUSH));
	 else if (crush)       n <= fromInteger (valueOf (N_CRUSH));
	 else if (big_crush)   n <= fromInteger (valueOf (N_BIG_CRUSH));
	 else if (diehard)     n <= fromInteger (valueOf (N_DIEHARD));
	 else if (nist)        n <= fromInteger (valueOf (N_NIST));
	 
      endaction
      
      // Initialize Mersenne Twister with default seed.
      rng.initialize (fromInteger (0));
      
      // Generate 2^N outputs.
      // Format: <Output Number> <Output Value in C Style Hex>

	$display("#==================================================================");
	$display("# generator Bluespec_WELL  seed = h012bd6aa");
	$display("#==================================================================");
	$display("type: d");
	$display("count: 500000000");
	$display("numbit: 32");

      while (i < (1 << n))
	 action
	    $display ("%d", rng.get ());
	    i <= i + 1;
	 endaction
      
   endseq;
   
   mkAutoFSM (verify_stmt);
   
endmodule: mkWell1024Tb



endpackage: Well1024Tb
