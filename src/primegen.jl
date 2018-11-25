using Primes


function keccak256(data::Vector{UInt8}) 
  result = zeros(UInt8, 32)
  ccall((:keccak256, "keccak256"), Int32, (Ref{UInt8}, Ref{UInt8}, Int32), result, data, length(data))
  return result
end

toBEBytes(p::UInt32) = UInt8[p[1]>>24, p[1]>>16 & 0xff, p[1]>>8 & 0xff, p[1] & 0xff]

function hashprimechunk(p::T) where T <: AbstractVector{UInt32}
  lp=length(p)
  if (lp>1)
    return keccak256(vcat(hashprimechunk(view(p, 1:div(lp, 2))), hashprimechunk(view(p, (div(lp, 2)+1):lp)  )))
  end
  return keccak256(toBEBytes(p[1]))
end


const PRIME_TREE_HEIGHT=24+1

function hashprimeset()
  preset = zeros(UInt8, (2^(PRIME_TREE_HEIGHT-4)-1)*32)
  primeset, intervals = gen_primeset()
  preset[((2^(PRIME_TREE_HEIGHT-5)-1)*32+1):((2^(PRIME_TREE_HEIGHT-4)-1)*32)] = intervals
  preset[((2^(PRIME_TREE_HEIGHT-6)-1)*32+1):((2^(PRIME_TREE_HEIGHT-5)-1)*32)] = reduce(vcat, [hashprimechunk(view(primeset, ((i-1)*64+1):(i*64))) for i = 1:2^(PRIME_TREE_HEIGHT-6)])
  for j = (PRIME_TREE_HEIGHT-7):-1:0
    preset[((2^j-1)*32+1):((2^(j+1)-1)*32)] = reduce(vcat, [ keccak256(preset[(((2^(j+1)-1)*32) + (i-1)*64 + 1):(((2^(j+1)-1)*32) + i*64)])  for i = 1:2^j ])
  end

  f=open("primes.dat", "w")
  unsafe_write(f, pointer(preset), (2^(PRIME_TREE_HEIGHT-4)-1)*32)
  close(f)

end

function gen_primeset()
  primes= zeros(UInt32, 2^PRIME_TREE_HEIGHT)
  intervals = zeros(UInt8, 2^PRIME_TREE_HEIGHT)
  primes[1]=3
  intervals[1]=1
  for i=2:2^PRIME_TREE_HEIGHT
    primes[i] = nextprime(primes[i-1]+1)
    intervals[i] = div(primes[i]-primes[i-1], 2)
  end
  return primes, intervals
end


result = zeros(UInt8, 32)
ccall((:keccak256, "keccak256"), Int32, (Ref{UInt8}, Ref{UInt8}, Int32), result, pointer("hello"), 5)


function main()
  hashprimeset()
end

main()