# tasm calculator !!

a basic calculator project built with turbo assembler (tasm) for our computer architecture lab.  
it supports arithmetic and logic operationsin binary, decimal, and hexadecimal bases. after each operation, flag values are displayed.

## features
- select base (binary, decimal, hexadecimal)
- perform operations: add, sub, mul, div, and, or
- display flags: zf, cf, sf, of
- simple text ui

## how to run
> this project was developed and tested using **DOSBox** and **TASM**  
>[TASM GitHub Repo (CS-TASM-x86)](https://github.com/slaee/CS-TASM-x86)

### open DOSBox
```bash
mount c path\to\your\project
c:
```
### go to the bin folder
```bash
cd bin
```
### run the compiled program
```bash
program.exe
```
#### (optional) if you want to recompile
```bash
cd ..
tasm program.asm
tlink program.obj
cd bin
program.exe
```

## credits
group project — computer architecture lab  
USTHB 2025
