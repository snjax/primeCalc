module blockRSAProver
using Primes



const TREE_HEIGHT=31
const NUM_DUSTS = 2^TREE_HEIGHT
const NUM_PRIMES= 2^(TREE_HEIGHT+2)
const NUM_PRIMEGAP = 382
const RSA_EXP = BigInt(17)
const RSA_N = 97372270460360183908685753642832486503852614438108435660643433011167559248476297570914369144778889897702551904986890699128932983084650751393101216083579352115547595929892340340151585704856377333927454643498275515801271881496764864925878644125303629789924640247928664970223581933164272794949949176634915569566197555510759624571985658236604916720208638847436443861383754696587481738616223497416490137861065647555446004138570916444839818760528128060776966359103255258465345348369125896602272311020575202699503670334417881935854311515383231962805474769348794777702248271611532457578664497602086903909606800556094966189497



function areintersected(a::T, b::T) where T<:Vector
  return (a[1] <= b[1] <= a[2]) || (a[1] <= b[2] <= a[2])
end

function join(a::T, b::T) where T<:Vector
  return [min(a[1], b[1]), max(a[2], b[2])]
end

function process_slices(s::T) where T <:Vector{<:Vector}
  sort!(s, lt=(a,b)->a[1] < b[1])
  println(s)
  res = eltype(s)[]
  s_length = length(s)
  i = 1
  while i <= s_length
    cur = s[i]
    i+=1
    while (i <= s_length) && areintersected(cur, s[i])
      cur = join(cur, s[i])
      i+=1
    end
    push!(res, cur)
  end
  return res
end



function bit(x::UInt64, n::T) where T <: Integer
  return x & (1 << n)
end


function merge_unique(s1::T, s2::T)  where T <:Vector{<:Integer}
  res = eltype(s1)[]
  i = 1
  j = 1
  s1_len = length(s1)
  s2_len = length(s2)
  while i < s1_len && j < s2_len
    if s1[i] < s2[j]
      push!(res, s1[i])
      i+=1
    else
      push!(res, s2[j])
      j+=1
      if s1[i] == s2[j]
        i+=1
      end
    end
  end
  return res
end

function slice_to_aligned_indexes(s::T) where T <:Vector{<:Integer}
  a, b = s
  t = 0
  q = 1
  res = UInt64[]
  while a + q < b
    if bit(a, t) == 1
      push!(res, 2 ^ (TREE_HEIGHT - t) + div(a,q))
      a += q
    end
    q <<= 1
    t += 1
  end
  while t >= 0
    if a + q <= b
      push!(res, 2 ^ (TREE_HEIGHT - t) + div(a,q))
      a += q
    end
    q >>= 1
    t -= 1
  end
  return res
end


      
function nprime(n::T) where T <: Integer
  @assert n < NUM_DUSTS
  p = n * NUM_PRIMEGAP
  while !isprime(p)
    p -= 1
  end
  return p
end


function rsa_accumulate(cin::T, cout::Channel{BigInt}) where T <: Channel{<:Vector}
  A = RSA_EXP
  while true
    p = take!(cin)
    for q in p
      A = powermod(A, q, RSA_N)
    end
    put!(cout, A)
  end
end

function chan_print(cin::T) where T<:Channel
  while true
    p = take!(cin)
    println(p)
  end
end

function chan_gen(cin::T) where T<:Channel
  while true
    put!(cin, [reduce(*, [BigInt(nprime(rand(UInt32, 1)[1])) for i = 1:64]) for j=1:256])
  end
end

cin = Channel{Vector{BigInt}}(10)
cout = Channel{BigInt}(10)

t1 = @async rsa_accumulate(cin, cout)
t2 = @async chan_print(cout)
chan_gen(cin)








# println(process_slices([[5,10], [1, 4], [3, 7]]))

end # module
