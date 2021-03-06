class VideosController < ApplicationController
  def new
    @pre_upload_info = {}
  end

  def index
    @videos = Video.all
    @videos = Video.order('created_at DESC')
  end

  def show 
    @video = Video.find(params[:id])
  end

  def get_video_uid
    video_uid = params[:id]
    v = current_user.videos.build(uid: video_uid)
    youtube = YouTubeIt::OAuth2Client.new(dev_key: ENV['GOOGLE_DEV_KEY'])
    yt_video = youtube.video_by(video_uid)
    v.title = yt_video.title
    v.description = yt_video.description
    v.answer = params[:answer]
    if v.save
      flash[:success] = 'Thanks for sharing your video!'
      redirect_to root_url
    else
      flash[:alert] = 'Something went wrong!'
      render :new
    end
  end

  def get_upload_token
    temp_params = { title: params[:title], description: params[:description], answer: params[:answer], category: 'Education',
                    keywords: [] }

    if current_user
      youtube = YouTubeIt::OAuth2Client.new(client_access_token: current_user.token,
                                            dev_key: ENV['GOOGLE_DEV_KEY'])

      upload_info = youtube.upload_token(temp_params, get_video_uid_url)

      render json: {token: upload_info[:token], url: upload_info[:url]}
    else
      render json: {error_type: 'Not authorized.', status: :unprocessable_entity}
    end
  end
end