class LinksController < ApplicationController
  before_filter :authorize, only: [:destroy]

  # GET /links
  def index
    if current_user
      @links = current_user.links
    else
      @links = Link.where(user_id: nil).order('created_at DESC')
    end
  end

  # GET /l/:short_name
  # See routes.rb for how this is set up.
  def show
    @link = Link.find_by_short_name(params[:short_name])

    if @link
      @link.clicked!
      redirect_to @link.url
    else
      render text: 'No such link.', status: 404
    end
  end

  # GET /links/new
  def new
    @link = Link.new
  end

  # POST /links
  def create
    @link = Link.new(link_params)
    @link.user_id = current_user.id if user_signed_in?

    if @link.save
      redirect_to root_url, notice: 'Link was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @link = Link.find_by_short_name(params[:short_name])
    @link.destroy

    redirect_to action: :index, notice: 'Link deleted!'
  end

  private
    # Only allow a trusted parameter "white list" through.
    def link_params
      params.require(:link).permit(:url, :shortname)
    end
end
