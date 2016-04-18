class Comfy::Blog::Post < ActiveRecord::Base
  
  self.table_name = 'comfy_blog_posts'
  
  # -- Relationships --------------------------------------------------------
  belongs_to :blog
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/avatar9.jpg"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
  
  has_many :comments,
    :dependent => :destroy
  has_one :comfy_blog_category
  
  # -- Validations ----------------------------------------------------------
  validates :blog_id, :title, :slug, :year, :month, :content,
    :presence   => true
  validates :slug,
    :uniqueness => { :scope => [:blog_id, :year, :month] },
    :format => { :with => /\A%*\w[a-z0-9_\-\%]*\z/i }
  
  # -- Scopes ---------------------------------------------------------------
  default_scope -> {
    order('published_at DESC')
  }
  scope :published, -> {
    where(:is_published => true)
  }
  scope :for_year, -> year {
    where(:year => year)
  }
  scope :for_month, -> month {
    where(:month => month)
  }
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :set_slug,
                    :set_published_at,
                    :set_date
  
protected
  
  def set_slug
    self.slug ||= self.title.to_s.downcase.slugify
  end
  
  def set_date
    self.year   = self.published_at.year
    self.month  = self.published_at.month
  end
  
  def set_published_at
    self.published_at ||= Time.zone.now
  end
  
end
