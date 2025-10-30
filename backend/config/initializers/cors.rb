Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      # In development: Allow frontend dev server (Vite on port 3000)
      # In production: CORS not needed (frontend served from same origin)
      origins_list = ENV.fetch("CORS_ORIGINS", Rails.env.development? ? "http://localhost:3000" : "").split(",").map(&:strip).reject(&:blank?)
      origins(*origins_list)
      resource "/api/*",
        headers: :any,
        methods: %i[get post put patch delete options],
        credentials: false
    end
  end