class Admin::JobsController < Admin::ApplicationController
  include Pagy::Method

  def index
    ready_scope = SolidQueue::Job.where(finished_at: nil)
                                 .left_joins(:failed_execution)
                                 .where(solid_queue_failed_executions: { id: nil })
                                 .order(created_at: :desc)

    failed_scope = SolidQueue::FailedExecution.includes(:job).order(created_at: :desc)

    @pagy_ready, @ready = pagy(ready_scope, limit: 20, page_param: :ready_page)
    @pagy_failed, @failed = pagy(failed_scope, limit: 20, page_param: :failed_page)

    @recurring = SolidQueue::RecurringTask.all rescue []

    @stats = {
      ready: ready_scope.count,
      failed: failed_scope.count,
      completed_today: SolidQueue::Job.where("finished_at >= ?", Date.current.beginning_of_day).count,
      total: SolidQueue::Job.count
    }

    respond_to do |format|
      format.html
      format.turbo_stream
    end
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
