class Comfy::Blog::PostsController < Comfy::Blog::BaseController

  skip_before_action :load_blog, :only => [:serve, :indexall]

  # due to fancy routing it's hard to say if we need show or index
  # action. let's figure it out here.
  def serve
     
    # if there are more than one blog, blog_path is expected
    if @cms_site.blogs.count >= 2
      params[:blog_path] = params.delete(:slug) if params[:blog_path].blank?
    end

    load_blog

    if params[:slug].present?
      if params[:slug] == "all_posts"
        indexall && render(:indexall)
      else
      show && render(:show)
      end
    else
      index && render(:index)
    end
  end

  def index
    scope = if params[:year]
      scope = @blog.posts.published.for_year(params[:year])
      params[:month] ? scope.for_month(params[:month]) : scope
    else
      @blog.posts.published
    end

    limit = ComfyBlog.config.posts_per_page
    respond_to do |format|
      format.html do
        @posts = comfy_paginate(scope, limit)
      end
      format.rss do
        @posts = scope.limit(limit)
      end
    end
    @feature_post = @blog.posts.published.where(comfy_blog_category_id: 1).order("published_at DESC").paginate(:page => params[:page], :per_page => 2)
    @normal_post = @blog.posts.published.where(comfy_blog_category_id: 2).order("published_at DESC").paginate(:page => params[:page], :per_page => 4)
    @quote_post = @blog.posts.published.where(comfy_blog_category_id: 3).order("published_at DESC").limit(1)
    @video_post = @blog.posts.published.where(comfy_blog_category_id: 4).order("published_at DESC").limit(1)
   end

  def indexall
    
        if @cms_site.blogs.count >= 2
      params[:blog_path] = params.delete(:slug) if params[:blog_path].blank?
    end

    load_blog
    
    scope = if params[:year]
      scope = @blog.posts.published.for_year(params[:year])
      params[:month] ? scope.for_month(params[:month]) : scope
    else
      @blog.posts.published
    end

    limit = ComfyBlog.config.posts_per_page
    respond_to do |format|
      format.html do
        @posts = comfy_paginate(scope, limit)
      end
      format.rss do
        @posts = scope.limit(limit)
      end
    end
    if params[:tag]
    @posts = @blog.posts.tagged_with(params[:tag]).paginate(:page => params[:page], :per_page => 5)
  else
   
    @posts = @blog.posts.published.order("published_at DESC").paginate(:page => params[:page], :per_page => 5)
   end
   @feature_post = @blog.posts.published.where(comfy_blog_category_id: 1).order("published_at DESC").paginate(:page => params[:page], :per_page => 2)
    @normal_post = @blog.posts.published.where(comfy_blog_category_id: 2).order("published_at DESC").paginate(:page => params[:page], :per_page => 4)
    @quote_post = @blog.posts.published.where(comfy_blog_category_id: 3).order("published_at DESC").limit(1)
    @video_post = @blog.posts.published.where(comfy_blog_category_id: 4).order("published_at DESC").limit(1)
 end
   

  def show
    @posts = @blog.posts.order("published_at DESC").limit(5)
    @post = if params[:slug] && params[:year] && params[:month]
      @blog.posts.published.where(:year => params[:year], :month => params[:month], :slug => params[:slug]).first!
    else
      @blog.posts.published.where(:slug => params[:slug]).first!
    end
    @comment = @post.comments.new
    @comments = @post.comments.paginate(:page => params[:page], :per_page => 2)
   

  rescue ActiveRecord::RecordNotFound
    render :cms_page => '/404', :status => 404
  end

end
