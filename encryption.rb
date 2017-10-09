#!/usr/bin/env ruby

def raiseToModulus a b n

end


def isPrime? n
  return raiseToModulus(a,n-1,n) == 1
end



# Compute based on arguments


if ARGV[0] == "-c" or ARGV[0] == "--create-key-pair"
  # Generate Random Number
  bitString = "1"
  (1...2048).each do
    bitString += rand(2).to_s
  end
  # bitString.to_i(2) #=> converts to int in base 10

elsif ARGV[0] == "-e" or ARGV[0] == "--encrypt"

elsif ARGV[0] == "-d" or ARGV[0] == "--decrypt"

else

end
