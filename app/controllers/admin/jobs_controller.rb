class Admin::JobsController < Admin::ApplicationController
  def index
    @ready = SolidQueue::Job.where(finished_at: nil)
                            .left_joins(:failed_execution)
                            .where(solid_queue_failed_executions: { id: nil })
                            .order(created_at: :desc).limit(50)

    @failed = SolidQueue::FailedExecution.includes(:job).order(created_at: :desc).limit(50)

    @recurring = SolidQueue::RecurringTask.all rescue []

    @completed_today = SolidQueue::Job.where("finished_at >= ?", Date.current.beginning_of_day).count

    @stats = {
      ready: @ready.count,
      failed: @failed.count,
      completed_today: @completed_today,
      total: SolidQueue::Job.count
    }
  end

  def retry_failed
    execution = SolidQueue::FailedExecution.find(params[:id])
    execution.retry
    redirect_to admin_jobs_path, notice: "Job relancé"
  rescue => e
    redirect_to admin_jobs_path, alert: "Erreur: #{e.message}"
  end

  def discard_failed
    SolidQueue::FailedExecution.find(params[:id]).discard
    redirect_to admin_jobs_path, notice: "Job supprimé"
  rescue => e
    redirect_to admin_jobs_path, alert: "Erreur: #{e.message}"
  end
end
