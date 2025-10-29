module RequestHelpers
  def json_response
    JSON.parse(response.body)
  end

  def auth_headers(user)
    { "X-User-Id" => user.id.to_s }
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end

