ECE 385 Final Project  
Members: Lizhuang Zheng & Haoran Yuan  
NetID: lzheng17 & haorany7  
Project: Modified version of the Google Chrome TRex Game.  

The project is a modified version of the Google Chrome TRex Game, with some new features added.  
This project is based on FPGA DE10-Lite and Quartus 18.1 LITE Edition, and need a VGA monitor and a USB keyboard.  
The top-level entity is lab62.sv, which is from ECE 385 lab 6.2, with some modifications.  
To start the game, press Space. Then you can press Space or Up ($\uparrow$) to control the dinosaur to jump over the obstacles like cactuses and pterosaurs. If you touched the obstacle, the game will over, and your score will be show on the screen, and your highest score will be recorded as well. Then you can press "Enter" to return to the start, and then press "Space" to run a new round. You can also press "Reset" (KEY0) on the FPGA board to reset the game, which will zero your highest score.  
Sometimes there will be a star flying towards the dinosaur, if you touched it, it will add 100 points to your score.  
At some point of time, the scene will be go into the night for a period of time.  
There is also an easter egg: During the game, press "IKUN" in order, your dinosaur will become a rapper star with middle part haircut, black shirts, white suspender trousers, playing with a basketball. We call it "IKUN" mode. You can press "Esc" or "Enter" to exit "IKUN" mode.  

There is a bug that we have no time to fix: sometimes the pictures of the cactus will be distorted, in a low possibility. This maybe because the metastability when changing the cactus types according to the random number. We suppose this can be fixed by turning "cactus_off=1" when we find the current cuctus type is not matched with the current cactus width.

To launch the game, you should first connect the FPGA DE10-Lite to the computer, VGA monitor, and the USB keyboard, after that you should compile the project, program to the FPGA, then go to the Eclipse, Run Configuration of the project "dino". 