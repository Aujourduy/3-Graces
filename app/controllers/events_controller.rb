class EventsController < ApplicationController
  include Pagy::Method

  def index
    # Pagy syntax: @pagy, @records = pagy(scope, limit: N)
    @pagy, @events = pagy(
      Event.futurs.includes(:professor).order(:date_debut),
      limit: 30
    )

    # Fragment cache key includes last updated event timestamp
    @cache_key = "events-index-#{Event.maximum(:updated_at)&.to_i || 0}"

    respond_to do |format|
      format.html # Render full page
      format.turbo_stream # Render partial for infinite scroll
    end
  end

  def show
    @event = Event.includes(:professor).find_by(slug: params[:id])

    unless @event
      redirect_to evenements_path, alert: "Événement introuvable"
      return
    end

    # Increment professor consultation counter (atomic SQL)
    Professor.increment_counter(:consultations_count, @event.professor_id) if @event.professor_id

    # Set SEO metadata (concern mixed in ApplicationController)
    # set_event_metadata defined in Epic 8 (SeoMetadata concern)
    # set_event_metadata(@event) if respond_to?(:set_event_metadata, true)
  end
end
