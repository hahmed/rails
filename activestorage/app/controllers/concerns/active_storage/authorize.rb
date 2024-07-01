# frozen_string_literal: true

module ActiveStorage::Authorize # :nodoc:
  extend ActiveSupport::Concern

  included do
    before_action :require_authorization
  end

  private
    def require_authorization
      head :forbidden unless authorized?
    end

    def authorized?
      @blob.try(:authorize_blob?) || true
    end
end
