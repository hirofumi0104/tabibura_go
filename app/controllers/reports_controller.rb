class ReportsController < ApplicationController
  # 通報機能のコントローラー
  
  before_action :authenticate_user!, only: [:create]
  
  before_action :authenticate_admin!, only: [:delete_reported_post]
  
   # 通報を作成する
  def create
    @report = current_user.reports.build(report_params)

    if @report.save
      flash[:success] = '通報が送信されました。'
    else
      flash[:error] = '通報の送信に失敗しました。'
    end
    redirect_back(fallback_location: root_path)
  end
  
  # 通報された投稿を削除する
  def delete_reported_post
    post = Post.find(params[:id])
    post.destroy
    redirect_to request.referer, notice: '投稿を削除しました。'
  end
  
  # 投稿への通報を取り消す
  def cancel_report
    post = Post.find(params[:id])
    reports = post.reports
    if reports.any?
      reports.destroy_all
      flash[:notice] = '通報を取り消しました。'
    else
      flash[:alert] = '通報情報が見つかりません。'
    end
    redirect_to admin_top_path
  end
  
  # コメントへの通報を取り消す
  def cancel_comment_report
    comment = Comment.find(params[:id])
    reports = comment.reports
    if reports.any?
      reports.destroy_all
      flash[:notice] = '通報を取り消しました。'
    else
      flash[:alert] = '通報情報が見つかりません。'
    end
    redirect_to admin_top_path
  end

  
  private

  def report_params
    params.require(:report).permit(:reason, :reportable_id, :reportable_type)
  end
end
