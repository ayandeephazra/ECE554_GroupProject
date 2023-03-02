# ECE554_GroupProject
Complex ISA with Dynamic Branch Predictor and VGA capabilities. 

Branch predictor, which is a seprate module, within the cpu module (with heed to pipeline).

Branch predictor -> Cache of sorts, stores like 4 branches (2 bits) with a bit to say whether it was taken or not. 
                     
                    a structure which stores:
                    
                    flop = 4*{PC 16:1, taken bit 0}
                    index bit 1:0 -> increment with every write to the cache

                    within the design, actively
                    
                    Decode, find out it is a branch instruction, if yes, check the cache(?) above and predict last outcome.
                    Comb logic for storing entries to the cache.
                    Do a reduction xor of a PC and use that as an index to the cache. 
