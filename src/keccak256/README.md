`g++ -s -shared -o keccak256.dll  -Wl,--subsystem,windows  keccak_lib.cpp keccak.cpp`

```julia
result = zeros(UInt8, 32)
ccall((:keccak256, "keccak256"), Int32, (Ref{UInt8}, Ref{UInt8}, Int32), result, pointer("hello"), 5)

```



