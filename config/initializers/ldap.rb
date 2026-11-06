# Report the deprecated LDAP environment variables once at boot, where operators read the logs.
Rails.application.config.after_initialize do
  LdapAuthenticator.warn_about_deprecated_settings
end
