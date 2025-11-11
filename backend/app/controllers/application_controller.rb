class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Serve React app's index.html for all frontend routes
  def fallback_index_html
    # Prevent caching of HTML to ensure users get latest version
    response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, proxy-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
    
    # Add ETag based on version file if it exists
    begin
      version_file = Rails.public_path.join('version.txt')
      if version_file.exist?
        version = version_file.read.strip
        response.headers['ETag'] = %("#{version}")
        response.headers['X-App-Version'] = version
      end
    rescue => e
      # Silently fail if version file can't be read
      Rails.logger.warn("Could not read version file: #{e.message}")
    end
    
    index_path = Rails.public_path.join('index.html')
    if index_path.exist?
      render file: index_path, layout: false
    else
      render plain: 'Application is being deployed. Please try again in a moment.', status: :service_unavailable
    end
  end
end
