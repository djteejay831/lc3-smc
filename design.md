Design Decisions

Stack Implementation/Memory Management

I chose to build my SMC utilizing a stack because of the register restrictions in the LC3. Registers do not persist across subroutine calls, nor can they store an unknown number of user inputs. I already felt register-starved when running the simple character checks and the arithmetic, so using a stack was the logical choice. I set the stack to start at xEFFF so that it had the least likelihood of clashing with my code, and I chose R6 as the stack pointer because of convention and readability for future readers. The stack helps ease the strain on register restriction because it allows the code to store both the numbers input by the user as well as the result before printing. 

Input Termination

In terms of user input, I chose to go with enter over space to enter and progress the user's input. Enter makes things easier for the calculator because I don't have to deal with parsing hrough to isolate each digit on the same line. With enter, the number being input is simultaneously separated by a new line, making it far easier to isolate and break down the digit to be pushed on the stack. In addition to that, "press enter to continue" has become a more universal input style than "press space to continue".

Number Accumulaion

Tackling the breakdown of multi-digit numbers was the hardest part of the code. At first, I thought it might be easier to just leave everything in ASCII format, but thinking through the arithmetic loops quickly became convoluted, so I decided to convert the numbers to decimal and do the arithmetic that way. GETC returns the ASCII value of whatever digit was entered, so I used a running accumulator that multiplies the previous total by 10 and adds each new digit as it arrives. After recieving the ASCII value of the digit from GETC, the loop multiplies (via multiple additions) the previous number (zero at start) by 10 and then adds the current number. For example, 0 * 10 + 1 = 1. The loop triggers again with the next digit, looping until the user presses enter. Once enter is pressed, the total is pushed onto the stack.
However, OUT only prints one ASCII character at a time, so this meant I had to do the same process in reverse. First, the code peeks at the top of the stack. That number is divided (via negation and then multiple additions) until it goes negative. Once negative, the loop adds 10 back one last time to get the remainder, which is then pushed to the stack. The quotient of that process then becomes the next digit to run this loop on, until the quotient reaches 0. Once it does, the digit counter that runs alongside this loop becomes the digit counter for how many iterations we need to pop the digits out of the stack to print. By the nature of how the stack works, printing the digit out from the stack was very simple since it was already in reverse order, which meant printing was as simple as popping in the usual order of last in, first out. 

Operator Dispatch 

I chose to work with if/else chains over a dispatch table because with just four operators, an if/else chain is straightforward, easy to read, and only 20 or 30 lines. Dispatch tables are arrays of subroutines in memory, and I would need to map each operator character to an index (0-3), load the corresponding address from a table in memory, and jump to it. If the code required many more operators, then I would have chosen a dispatch table, since adding a new operator would only require one new table entry rather than another branch in the chain.

Memory Layout

Once my code began to near completion, it was relatively lengthy. It was then that I began to run into issues with the PC-relative 9-bit offset. I couldn't assemble the code because the data section was too far from the code that was calling it. At first, I thought that maybe LEA and LDR could be the fix over simply loading the immediate value of a label into a register via LD, so I meticulously went through and rewrote many of my lines as LEA R0, LABEL followed by LDR R0, R0, #0 instead of the simple LD R0, LABEL that I had started with. However, that turned out to not make a difference, so my next idea was to move the data section closer to the lines of code that were calling it. Moving the data section to the top solved some of the 9-bit offset restriction, but not all of it. I then decided to break the data section in half, moving the labels used later in the code down to the middle. 

Known Limitations

For a full list of known limitations, see the [README](https://github.com/djteejay831/lc3-smc/blob/main/README.md).
