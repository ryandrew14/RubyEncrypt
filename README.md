# RubyEncrypt
## A homemade RSA encryption program.

An Encryption algorithm made in ruby after learning about RSA encryption standards in CS1800.

Made by [Bryce Thuilot](https://www.github.com/bthuilot) and [Ryan Drew](https://www.github.com/ryandrew14)

## RubyEncrypt-visual
This update provides a GUI for RubyEncrypt, built using [visual ruby](http://visualruby.net/) and [glade](https://glade.gnome.org/).

### To Install:
```
gem install rbencrypt2
```
#### After typing the correct email into the text box, a user can:
- Create keys using the Create button.
  - a public and private keypair will be created and stored in ~/.bre, and registered to ~/.bre/keys.json.
- Add an existing public key to the keychain using the Add button.
  - the key must be placed on the desktop, with its name being "local-part-of-email.pub".
  - for example, if the entered email is bob01@test.com, the file name would need to be "bob01.pub".
- Encrypt and decrypt text using the Encrypt button
  - its corresponding key must have already been added to the keychain.
  - the Encrypt button opens a window where the message can be entered into a text box and encrypted or decrypted.

## About

The encryption schemes creates a key pair (public and private) and stores them in a folder called ~/.bre located in the user's home directory, recording them inside a .json file which serves as the "keychain".

Existing keys can also be added, copying them into the ~/.bre directory and adding them to the keychain .json file.

## Usage (old)

Run encryption.rb with arguments
- -c to create a pair
- -a <key-location> to add a key to the keychain
- -s <key-location> to add a secret key to the keychain
- -e <file-location> to encrypt the contents of a file
- -d <file-location> to decrypt the contents of a file
