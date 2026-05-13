# Examples

## Basic Addition: 6 + 4 = 10
```
Step 1: Type 6, press Enter
Step 2: Type 4, press Enter
Step 3: Type +, press Enter
Step 4: Type ., press Enter
Result: 10
```

## Chained Addition: 5 + 5 + 5 = 15
```
Step 1: Type 5, press Enter
Step 2: Type 5, press Enter
Step 3: Type +, press Enter  (result 10 is now on stack)
Step 4: Type 5, press Enter
Step 5: Type +, press Enter
Step 6: Type ., press Enter
Result: 15
```

## Negative Result: 4 - 5 = -1
```
Step 1: Type 4, press Enter
Step 2: Type 5, press Enter
Step 3: Type -, press Enter
Step 4: Type ., press Enter
Result: -1
```

## Error Case: Operator with no numbers
```
Step 1: Type +, press Enter
Result: $ (stack error, calculator resets)
```

## Divide by Zero
```
Step 1: Type 5, press Enter
Step 2: Type 0, press Enter
Step 3: Type /, press Enter
Result: ? (error, calculator resets)
```

Note: each input must be confirmed with Enter before the next. 
Operators are applied to the two most recent numbers on the stack.
