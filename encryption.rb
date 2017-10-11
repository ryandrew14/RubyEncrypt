#!/usr/bin/env ruby
require 'prime'

# To do crazy powers of a ** b % n
def raiseToModulus a, b, n
  b < 0 and raise ArgumentError, "negative exponent"
     prod = 1
     a %= n
     until b.zero? do
       if b.odd?
         prod = (prod * a) % n
       end
       b /= 2
       a = (a ** 2) % n
     end
     prod
end

# Primality Test
def miller_rabin_prime?(n, g)
  d = n - 1
  s = 0
  while d % 2 == 0 do
    d /= 2
    s += 1
  end
  g.times do
    a = 2 + rand(n - 4)
    x = raiseToModulus(a, d, n) # x = (a**d) % n
    next if x == 1 || x == n - 1
    for r in (1..s - 1)
      x = raiseToModulus(x, 2, n) # x = (x**2) % n
      return false if x == 1
      break if x == n - 1
    end
    return false if x != n - 1
  end
  true # probably
end

# Actaully Testing primality
def isPrime? n
  Prime.each(10000) do |num|
    if ( raiseToModulus num, n-1, n ) != 1 or n % num == 0
      return false
    end
  end
  return miller_rabin_prime?(n, 10)
end

## Determine the Mult. Inv.

# Euclidian Algorithim
def extended_gcd(a, b)
  last_remainder, remainder = a.abs, b.abs
  x, last_x, y, last_y = 0, 1, 1, 0
  while remainder != 0
    last_remainder, (quotient, remainder) = remainder, last_remainder.divmod(remainder)
    x, last_x = last_x - quotient*x, x
    y, last_y = last_y - quotient*y, y
  end

  return last_remainder, last_x * (a < 0 ? -1 : 1)
end

def invmod(e, et)
  g, x = extended_gcd(e, et)
  if g != 1
    raise 'The maths are broken!'
  end
  x % et
end

# genrate x bit number
def randomBitNum x
  bitString = "1"
  (1...x).each do
    bitString += rand(2).to_s
  end
  return bitString.to_i(2)
end

# Compute based on arguments


if ARGV[0] == "-c" or ARGV[0] == "--create-key-pair"
  # Generate 2 Random Numbers
  randNums = []
  (0..1).each do |i|
    # Generate Random Num
    value = randomBitNum 1024
    # If even, make odd
    if value % 2 == 0
      value += 1
    end
    # Check if number generated is prime
    # Add 2 if not, until prime
    while not isPrime? value do
      value += 2
    end
    randNums[i] = value
  end
  n = randNums[0] * randNums[1]
  coprime = (randNums[0] - 1) * (randNums[1] - 1)
  e = randomBitNum 1024
  until (coprime.gcd(e) == 1) and (isPrime? e )do
    e += 1
  end
  d =  invmod(e,coprime)
  if not File.directory?('~/.thuilot-drew-encrypt')
    Dir.mkdir '~/.thuilot-drew-encrypt'
  end
  puts "Please enter a name for the key"
  name = gets.chomp
  File.open("~/.thuilot-drew-encrypt/#{name}.pub", 'w') do |file|
    file.write(e.to_s + "|\n|" + n.to_s)
  end
  File.open("~/.thuilot-drew-encrypt/#{name}.sec", 'w') do |file|
    file.write(d.to_s + "|\n|" + n.to_s)
  end

elsif ARGV[0] == "-e" or ARGV[0] == "--encrypt"

elsif ARGV[0] == "-d" or ARGV[0] == "--decrypt"

else

end
