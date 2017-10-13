#!/usr/bin/env ruby

require 'json'
require 'tty-spinner'
require 'prime'

# Loading Icon
spinner = TTY::Spinner.new("[:spinner] Generating Key...",format: :arrow_pulse,hide_cursor: true)


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

# Method to encrypt
def encrypt filePath, keyLocation
  dataToEncrypt = File.read(filePath)
  charArray = dataToEncrypt.split("")
  toEncrypt = ""
  charArray.each do |char|
    if char.ord.to_s(8).length == 2
      toEncrypt += "0" + char.ord.to_s(8)
    else
      toEncrypt += char.ord.to_s(8)
    end
  end
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
def decrypt filePath, keyLocation
  # get numbers for encryption
  dAndN = File.read(keyLocation)
  d = dAndN[(dAndN.index("\n") + 1)..-1]
  d = d[0...d.index("\n")]
  n = dAndN[(dAndN.index("\n") + 1)..-1]
  n = n[(n.index("\n") + 1)..-1]

  # Get encryptedText
  encryptedText = File.read(filePath)
  encryptedText = encryptedText[(encryptedText.index("\n")+1)..-1]
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


#### Compute based on arguments

if ARGV[0] == "-c" or ARGV[0] == "--create-key-pair"
  # Get a name for the key pair
  puts "Please enter a email for the key pair:"
  name = STDIN.gets.chomp
  # Generate 2 Random Numbers
  # p and q
  spinner.auto_spin
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
  spinner.stop("Done!")

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

elsif ARGV[0] == "-e" or ARGV[0] == "--encrypt"
  ### Get name to encrypt

  found = false
  until found

    # Get the email to encrypt to
    puts "Please enter an email to encrypt to (type exit to quit)"

    # Exit loop if you have the wrong email
    email = STDIN.gets.chomp
    if email == "exit"
      exit
    end
    # Get list of emails
    if File.file?(File.expand_path('~')+"/.bre/keys.json")
      keysFile = File.read(File.expand_path('~')+"/.bre/keys.json")
      key_hash = JSON.parse(keysFile)
    else
      # No keys in hash
      puts "No keys found call with -a to add keys"
      exit
    end
    # Check hash for email
    if key_hash.key?(email)
      found = true
      if ARGV.length > 1
        if (ARGV.size > 2)
          fileToWrite = Dir.pwd+"/" + ARGV[3]
        else
          fileToWrite = ARGV[1]+".encrypted"
        end
        File.open(fileToWrite, 'w') do |file|
          file.write(email + "\n" + encrypt(ARGV[1], File.expand_path('~') + "/.bre/" + key_hash[email]["location"]).to_s)
        end
      else
        puts "please enter a file as the second argument"
      end
    else
      puts "Sorry, email not found"
    end
  end

elsif ARGV[0] == "-d" or ARGV[0] == "--decrypt"
  if ARGV.length > 1
    # Get email
    email = File.read(ARGV[1])
    email = email[0...email.index("\n")]

    # Load in key hash
    keysFile = File.read(File.expand_path('~')+"/.bre/keys.json")
    key_hash = JSON.parse(keysFile)

    # check key hash
    if key_hash.key?(email)
      if key_hash[email].key?("secret")
        if (ARGV.size > 3)
          fileToWrite = Dir.pwd + "/" + ARGV[3]
        else
          fileToWrite = ARGV[1]+".txt"
        end
        File.open(fileToWrite, 'w') do |file|
          file.write(decrypt(ARGV[1], File.expand_path('~')+"/.bre/" + key_hash[email]["secret"]))
        end
      else
        puts "Please add secret key for #{email}"
      end
    else
      puts "Key for #{email} not found"
    end
  else
      puts "please enter a file as the second argument"
  end

elsif ARGV[0] == "-a" or ARGV[0] == "--add-key"
  # Get the location of a public key
  puts "please give location of public key to add:"
  loc = STDIN.gets.chomp

  # Get email from the given key
  email = File.read(loc)[0..index("\n")]

  # Copy to the folder with username as file name
  system("cp #{loc} "+File.expand_path('~')+"/.bre/#{email[0...index("@")]}.pub")

  # Open up keys.json to add key to register
  if File.file?(File.expand_path('~')+"/.bre/keys.json")
    keysFile = File.read(File.expand_path('~')+"/.bre/keys.json")
    key_hash = JSON.parse(keysFile)
  else
    key_hash = {}
  end

  # Assign it a hash value
  key_hash[email] = { location: "#{name[0...name.index("@")]}.pub" }

  # Write to register
  File.open(File.expand_path('~')+"/.bre/keys.json", 'w') do |file|
    file.write(key_hash.to_json)
  end

elsif ARGV[0] == "-s" or ARGV[0] == "--add-secret-key"

  # Get the email of the public key to associate the secret key with
  puts "Enter email of public key to add secret key:"
  email = STDIN.gets.chomp

  # Get the location of the secret key
  puts "Enter the location of the secret key:"
  loc = STDIN.gets.chomp

  # Copy to the folder with username as file name
  system("cp #{loc} "+File.expand_path('~')+"/.bre/#{email[0...index("@")]}.sec")

  # Check to see if keys file is there
  if File.file?(File.expand_path('~')+"/.bre/keys.json")
    keysFile = File.read(File.expand_path('~')+"/.bre/keys.json")
    key_hash = JSON.parse(keysFile)
  else
    key_hash = {}
  end

  # Assign it a hash value
  key_hash[email][:secret] = "#{email[0...index("@")]}.sec"

  # Write to register
  File.open(File.expand_path('~')+"/.bre/keys.json", 'w') do |file|
    file.write(key_hash.to_json)
  end

else
  puts "Usage:"
  puts "-c to create a key pair\n-e \<file-location\> to encrypt the contents of file\n\t -o <file-output> to specify the output\n-d \<file-location\> to decrypt the contents of file\n\t -o <file-output> to specify the output\n-a \<key-location\> to add key\n-s \<key-location\>to add secret key"
end
