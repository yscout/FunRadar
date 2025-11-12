require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /home" do
    before do
      allow(Rails.application.config.assets).to receive(:compile).and_return(false)
      allow_any_instance_of(ActionView::Base).to receive(:javascript_include_tag).and_return("")
    end

    it "returns http success" do
      get "/pages/home"
      expect(response).to have_http_status(:success)
    end

    it "renders the home page" do
      get "/pages/home"
      expect(response).to have_http_status(:success)
      expect(response.body).to be_present
    end
  end

end
