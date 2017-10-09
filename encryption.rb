#!/usr/bin/env ruby


# Generate Random Number
bitString = "1"
(1...2048).each do
  bitString += rand(2).to_s
end

# bitString.to_i(2) #=> converts to int in base 10

def raiseToModulus a b n

end


def isPrime? n
  return raiseToModulus(a,n-1,n) == 1
end
