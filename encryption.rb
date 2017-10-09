#!/usr/bin/env ruby

def raiseToModulus a, b, n

end


def isPrime? n
  listOfPrimes = [ 2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167,173, 179, 181, 191, 193, 197, 199,]
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
