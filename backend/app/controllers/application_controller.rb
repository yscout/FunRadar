class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Serve React app's index.html for all frontend routes
  def fallback_index_html
    response.headers['Cache-Control'] = 'no-store'
    render file: Rails.public_path.join('index.html'), layout: false
  end
end
