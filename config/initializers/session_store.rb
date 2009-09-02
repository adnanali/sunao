# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_sunao_session',
  :secret      => 'ac7cbbcd6ed3bf9720faddf43ec95b6bcbaaa51a0d7f83cce011225c156641250e9b07b601105aaf4afccc58b440cba075dece9b7ce298243899bd2af2421e2e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
