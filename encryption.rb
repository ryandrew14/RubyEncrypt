#!/usr/bin/env ruby
# RSA
# Step 1: Pick p and q (both prime)
# Step 2: n = p * q = modulus
# Step 3: phi(n) = (p-1) * (q-1) (amount of primes not coprime to p or q, up to the modulus)
# Step 4: d * e mod((p-1) * (q-1)) = 1
## Criteria for e
## 1. coprime with (phi(n), n)
## 2. 1 < e < phi(n)
# Step 5: Choose d such that d * e mod (phi(n)) = 1 (d is secret, e is public)

# public info: (e, n)
# private info: (d, p, q)

# to encrypt: raise your number x ^ e, mod n;
# to decrypt: raise the encrypted message m ^ d, mod n

def raiseToModulus a, b, n

end


def isPrime? n
  listOfPrimes = [ 2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,
    79,83,89,97,101,103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163,
    167, 173, 179, 181, 191, 193, 197, 199,]
  listOfPrimes.each do |num|
    if ( raiseToModulus num, n-1, n ) != 1
      return false
    end
  end
  return true
end

# Compute based on arguments


if ARGV[0] == "-c" or ARGV[0] == "--create-key-pair"
  # Generate Random Number
  bitString = "1"
  (1...1024).each do
    bitString += rand(2).to_s
  end
  # Get integer value
  value = bitString.to_i(2) #=> converts to int in base 10
  if value % 2 == 0
    value += 1
  end
  # Check if number generated is prime
  while not isPrime? value
    value += 2
  end

elsif ARGV[0] == "-e" or ARGV[0] == "--encrypt"

elsif ARGV[0] == "-d" or ARGV[0] == "--decrypt"

else

end
