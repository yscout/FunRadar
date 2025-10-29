if Rails.env.development? && ENV["OPENAI_KEY"].blank?
  Rails.logger.warn("OPENAI_KEY is not set; AI suggestions will fall back to canned results.")
end