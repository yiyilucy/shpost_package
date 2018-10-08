# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
#ShpostPackage::Application.config.secret_key_base = '9fd16346b0a3e614d399270d6c4c220d7bcbe0c088dba555918cea614cb975da7ef8abe050b31120f86545b0253c86849a10d704a09cbdbd98e8659ba3c259c1'
def secure_token
  token_file = Rails.root.join('.secret')
  if File.exist?(token_file)
    # Use the existing token.
    File.read(token_file).chomp
  else
    # Generate a new token and store it in token_file.
    token = SecureRandom.hex(64)
    File.write(token_file, token)
    token
  end
end

ShpostPackage::Application.config.secret_key_base = secure_token