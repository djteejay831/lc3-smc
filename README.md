# lc3-smc
LC-3 assembly version of an RPN calculator, built as a final project for a computer architecture course.

The Simple Math Calculator (SMC) is a basic arithmetic calculator built in LC-3 assembly that accepts numeric input and performs operations using a stack in memory. Invalid input is ignored automatically. 

The calculator uses Reverse Polish Notation (RPN), a format where operators come after their operands instead of between them. For example, instead of entering 3 + 4, a user enters 3, then 4, then +. The calculator pushes each number to a stack in memory, and when an operator is entered, it pops the top two numbers off the stack, applies the operator, and pushes the result back. This makes the order of operations unambiguous without needing parentheses, and maps naturally to how stack-based processors work. 


Installation
Visit https://github.com/chiragsakhuja/lc3tools/releases/latest and download the latest version for your system. Once installed, open LC3Tools and use File -> Open to load smc.asm. Click the wrench icon in the upper left to assemble the code. Once assembled, navigate to the simulator (CPU icon, upper right) and click Run. Note: these instructions have only been tested on Windows - for Linux and Mac installation help, refer to the LC3Tools documentation on GitHub.

How to Use
This calculator uses RPN, so operators come after their operands rather than between them. For example, 4 + 5 is entered as 4, Enter, 5, Enter, +, Enter. Each number must be confirmed by pressing Enter before moving on. Enter . followed by Enter to display the result.
The calculator displays four prompts: > means ready for input, ? means the input doesn't make sense (such as entering an operator with fewer than two numbers on the stack), and ! indicates numeric overflow or underflow. Upon any error, the calculator resets automatically.
Example: To calculate 100 ÷ 5, enter 100, press Enter, 5, press Enter, /, press Enter, then . and Enter to display 20.
Furthermore, to do operations with multiple iterations of the operation (such as 5^3 or 5 * 5 * 5), enter the respective additional operators. For example, to do 5^3, the input would be 5 5 5 * *. 

Limitations
Staying true to the "S" in SMC, the calculator does have some limitations. 
- No negative number input. Results can be negative, but negative numbers cannot be entered.
- No decimal support, integers only.
- No remainder display for division. 7 / 2 returns 3, not 3.5.
- Overflow for large multiplication gives truncated/incorrect results. Anything exceeding -32768 or 32767
- 4 digits per number max. Input limited to 0-9999, entering a 5th digit will trigger the "!" prompt and reset the calculator.
- No way to clear the stack without reset. An error must occur to reset.

Examples

6, 4, +, .        -> 10
5, 5, +, 5, +, .  -> 15
4, 5, -, .        -> -1
5, 0, /           -> ? (divide by zero, resets)
+                 -> $ (stack error, resets)

Note: each value must be confirmed with enter before the next input. For chained operations like 5 + 5 + 5, apply the operator after every two numbers rather than at the end.
