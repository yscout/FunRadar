require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /home" do
    # Skipped: This test requires frontend assets to be compiled (application.js)
    # The backend API functionality is tested separately in api/* specs
    xit "returns http success" do
      get "/pages/home"
      expect(response).to have_http_status(:success)
    end
  end

end
