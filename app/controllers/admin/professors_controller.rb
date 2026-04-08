class Admin::ProfessorsController < Admin::ApplicationController
  include Pagy::Method
  before_action :find_professor, only: [ :edit, :update, :mark_reviewed ]

  def index
    # Filter by status if requested
    scope = if params[:status] == "auto"
      Professor.where(status: "auto").order(created_at: :desc)
    else
      Professor.order(created_at: :desc)
    end

    if params[:q].present?
      params[:q].strip.split(/\s+/).each do |word|
        pattern = "%#{word}%"
        scope = scope.where("professors.prenom ILIKE :p OR professors.nom ILIKE :p OR professors.email ILIKE :p", p: pattern)
      end
    end

    @professors = scope.all

    # Count professors pending review for alert
    @pending_review_count = Professor.where(status: "auto").count

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    # Show form to edit professor details
  end

  def update
    if @professor.update(professor_params)
      redirect_to admin_professors_path, notice: "Professeur mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def mark_reviewed
    # Mark professor as reviewed (change status from "auto" to "reviewed")
    @professor.update!(status: "reviewed")
    redirect_to admin_professors_path, notice: "Professeur #{@professor.prenom} #{@professor.nom} marqué comme vérifié."
  end

  private

  def find_professor
    @professor = Professor.find(params[:id])
  end

  def professor_params
    params.require(:professor).permit(:prenom, :nom, :email, :site_web, :bio, :avatar_url)
  end
end
