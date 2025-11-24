Rails.application.config.session_store :redis_store,
                                       url: "#{ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379')}/0/session",
                                       expire_after: 30.days,
                                       key: "_piaback_session_#{Rails.env}",
                                       domain: ENV.fetch("DOMAIN_NAME", "localhost"),
                                       threadsafe: true,
                                       secure: Rails.env.production?,
                                       same_site: :lax,
                                       httponly: true

Rails.application.config.middleware.use ActionDispatch::Cookies
Rails.application.config.middleware.use Rails.application.config.session_store, Rails.application.config.session_options
