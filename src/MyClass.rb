#!/usr/bin/env ruby

require 'json'
require 'prime'

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

# Get multi. Inv. based on eculidian algorithim
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

def createKeyPair email
  # converting from command line code to function
  name = email

  # Array to store p and q
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

  # n = p * q
  n = randNums[0] * randNums[1]
  # coprime = (p - 1) * (q - 1)
  coprime = (randNums[0] - 1) * (randNums[1] - 1)
  # Generate e randomly
  e = randomBitNum 1024
  # Keep incrementing until e is co prime with (p - 1) * (q - 1)
  # and e is prime
  until (coprime.gcd(e) == 1) and (isPrime? e )do
    e += 1
  end
  # D is the mult. inv. of e and (p - 1) * (q - 1)s
  d =  invmod(e,coprime)
  
  # Create a folder if not there
  if not File.directory?(File.expand_path('~')+'/.bre')
    Dir.mkdir File.expand_path('~')+'/.bre'
  end

  # Write to pub and sec keys
  File.open(File.expand_path('~')+"/.bre/#{name[0...name.index("@")]}.pub", 'w') do |file|
    file.write(name + "\n" + e.to_s + "\n" + n.to_s)
  end
  File.open(File.expand_path('~')+"/.bre/#{name[0...name.index("@")]}.sec", 'w') do |file|
    file.write(name + "\n" + d.to_s + "\n" + n.to_s)
  end

  ## Add key to resgister

  # Check if register exists
  if File.file?(File.expand_path('~')+"/.bre/keys.json")
    keysFile = File.read(File.expand_path('~')+"/.bre/keys.json")
    key_hash = JSON.parse(keysFile)
  else
    key_hash = {}
  end

  # add key's hash value to register
  key_hash[name] = { location: "#{name[0...name.index("@")]}.pub", secret: "#{name[0...name.index("@")]}.sec" }

  # Write to the register
  File.open(File.expand_path('~')+"/.bre/keys.json", 'w') do |file|
    file.write(key_hash.to_json)
  end
end

def addKey email
  emailName = email.split("@").first
  loc = File.expand_path("~")+"/Desktop/"+emailName+".pub"
  
  # Copy to the folder with username as file name
  system("mv #{loc} "+File.expand_path('~')+"/.bre/#{emailName}.pub")

  # Open up keys.json to add key to register
  if File.file?(File.expand_path('~')+"/.bre/keys.json")
    keysFile = File.read(File.expand_path('~')+"/.bre/keys.json")
    key_hash = JSON.parse(keysFile)
  else
    key_hash = {}
  end

  # Assign it a hash value
  key_hash[email] = { location: "#{emailName}.pub" }

  # Write to register
  File.open(File.expand_path('~')+"/.bre/keys.json", 'w') do |file|
    file.write(key_hash.to_json)
  end
end

# Method to encrypt
def encrypt text, email
  dataToEncrypt = text
  charArray = dataToEncrypt.split("")
  toEncrypt = ""
  charArray.each do |char|
    if char.ord.to_s(8).length == 2
      toEncrypt += "0" + char.ord.to_s(8)
    else
      toEncrypt += char.ord.to_s(8)
    end
  end
  emailName = email.split("@").first
  keyLocation = File.expand_path("~")+"/.bre/"+emailName+".pub"
  eAndN = File.read(keyLocation)
  e = eAndN[(eAndN.index("\n") + 1)..-1]
  e = e[0...e.index("\n")]
  n = eAndN[(eAndN.index("\n") + 1)..-1]
  n = n[(n.index("\n") + 1)..-1]
  toEncrypt = toEncrypt.scan(/.{1,300}/)
  encrypted = ""
  toEncrypt.each do |encrypt|
    pre = ""
    while encrypt[0] == "0" do
      pre += "0|"
      encrypt = encrypt[1..-1]
    end
    encrypted += pre + raiseToModulus(encrypt.to_i, e.to_i, n.to_i).to_s + "|"
  end
  return encrypted
end

# Method to decrypt
def decrypt text, email
  emailName = email.split("@").first
  keyLocation = File.expand_path("~")+"/.bre/"+emailName+".sec"
  # get numbers for encryption
  dAndN = File.read(keyLocation)
  d = dAndN[(dAndN.index("\n") + 1)..-1]
  d = d[0...d.index("\n")]
  n = dAndN[(dAndN.index("\n") + 1)..-1]
  n = n[(n.index("\n") + 1)..-1]

  # Get encryptedText
  encryptedText = text
  encryptedText = encryptedText.split("|")
  # Convert Back
  decryptedText = ""
  encryptedText.each do |encrypt|
    decryptedText += raiseToModulus(encrypt.to_i, d.to_i, n.to_i).to_s
  end
  #decryptedText= decryptedText.to_i
  # Cut string up into thirds
  #decryptedText = decryptedText.to_s(8)
  decryptedText = decryptedText.scan(/.{1,3}/)
  # Loop through to turn each back into letter
  text = ""
  decryptedText.each do |letter|
    text += letter.to_i(8).chr
  end
  return text
end

class MyClass #(change name)
 
  include GladeGUI

  def create__clicked(*args)
    email = @builder["input"].text
    if email.length >= 1
      alert "Click OK to go. This may take some time."
      createKeyPair(email)
      alert "Finished! Check ~/.bre to find the keychain."
      @builder["create"].label = "Created!"
    else
      alert "Invalid email!"
      @builder["create"].label = "Create"
    end
  end
  
  def add__clicked(*args)
    keyLoc = @builder["input"].text
    if keyLoc.length >= 1
      addKey(keyLoc)
      alert "Key added! Check ~/.bre to find the keychain."
    else
      alert "Invalid location!"
    end
  end

  def crypt__clicked(*args)
    email = @builder["input"].text
    if email.length >= 1
      @builder["window2"].show
    else
      alert "Invalid email!"
    end
  end

  def encrypt__clicked(*args)
    filePath = @builder["input"].text
    toEncrypt = @builder["textinput"].text
    encryptedText = encrypt(toEncrypt, filePath)
    @builder["textinput"].text = encryptedText
  end

  def decrypt__clicked(*args)
    filePath = @builder["input"].text
    toDecrypt = @builder["textinput"].text
    decryptedText = decrypt(toDecrypt, filePath)
    @builder["textinput"].text = decryptedText
  end
  
  def help__clicked(*args)
    alert "Add: must be used to add a .pub file which is on the desktop, \nthe name of it being 'local-part-of-email.pub'. For more \ninformation, visit https://github.com/ryandrew14/RubyEncrypt."
  end
end

