# Ruby Homemade Encryption
## Bryce-Ryan Encryption

An Encryption algorithm made in ruby after learning about RSA encryption standards in CS1800

Made by [Bryce Thuilot](https://www.github.com/bthuilot) and [Ryan Drew](https://www.github.com/ryandrew14)

## About

The encryption schemes creates a key pair (public and private) and stores them in a folder called .bse/ located in the user's' home directory, inside a .json file which serves as the "keychain".

When a key is added, whether public or private, it is copied into the folder as well.

## Usage

Run encryption.rb with arguments
- -c to create a pair
- -a <key-location> to add a key to the keychain
- -s <key-location> to add a secret key to the keychain
- -e <file-location> to encrypt the contents of a file
- -d <file-location> to decrypt the contents of a file
