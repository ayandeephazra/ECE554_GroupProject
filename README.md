# ECE554_GroupProject
Complex ISA with Dynamic Branch Predictor and VGA capabilities that includes a custom-indie game wherein a player tries to dodge asteroids as a spaceship pilot. 

Our game showcases how a CPU can improve efficiency by implementing dynamic branch prediction. Our game code contains image movement subroutines that are connected together through branches. When branch prediction is disabled, the speed of the game is slow due to all game branch instructions flowing through the CPU pipeline every time the spaceship or meteor moves or collides with each other. But when branch prediction is activated, the game’s speed dramatically increases because the branch predictor determines which branch will be taken without the need to flow through the CPU.

If a branch predictor makes our game notably faster, it would be able to improve any CPU instruction pipeline speed. CPUs would be able to solve complex equations faster in any field of research, increase computer graphics, or allow for more computer applications to run simultaneously. 

Our branch prediction design can also have positive environmental impacts because of energy efficiency and less E-waste. A more efficient CPU means it is more energy-efficient. Less energy is consumed in the CPU if branch prediction improves the CPU pipeline flow. And less energy means less energy consumption is required to power the computer the branch predicting CPU is within. Also, E-waste is decreased from the increased efficiency because the CPUs will not have to perform at maximum production to run anymore. 
