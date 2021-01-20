class VideosController < ApplicationController
  before_action :require_video, only: [:show]

  def index
    if params[:query]
      data = VideoWrapper.search(params[:query])
    else
      data = Video.all
    end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @video.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory]
        )
      )
  end

  def create
    video = Video.new(video_params)

    video.inventory ||= 0

    if video.save
      render status: :ok, json: video.as_json(only: [:id, :title, :overview, :release_date, :image_url, :external_id])
    else
      render status: :bad_request, json: { errors: video.errors.messages }
    end
  end

  private

  def require_video
    @video = Video.find_by(title: params[:title])
    unless @video
      render status: :not_found, json: { errors: { title: ["No video with title #{params["title"]}"] } }
    end
  end

  def video_params
    return params.require(:video).permit(:title, :overview, :release_date, :inventory, :image_url, :external_id)
  end
end
