class Admin::ApplicationController < ActionController::Base
  before_action :restrict_to_tailscale
  http_basic_authenticate_with(
    name: ENV.fetch("ADMIN_USERNAME", "admin"),
    password: ENV.fetch("ADMIN_PASSWORD", "changeme")
  )

  before_action :set_admin_meta_tags
  layout "admin"

  private

  TAILSCALE_RANGE = IPAddr.new("100.64.0.0/10")

  def restrict_to_tailscale
    return if Rails.env.test?
    return if TAILSCALE_RANGE.include?(request.remote_ip)

    render plain: "Access denied", status: :forbidden
  end

  def set_admin_meta_tags
    set_meta_tags(robots: "noindex, nofollow")
  end
end
