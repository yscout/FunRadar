Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins_list = ENV.fetch("CORS_ORIGINS", Rails.env.development? ? "http://localhost:5173" : "").split(",").map(&:strip).reject(&:blank?)
      origins(*origins_list)
      resource "/api/*",
        headers: :any,
        methods: %i[get post put patch delete options],
        credentials: false
    end
  end