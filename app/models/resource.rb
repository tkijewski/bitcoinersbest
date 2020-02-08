class Resource < ApplicationRecord
  CATEGORIES = {
    podcast: 'Podcast'.freeze,
    episode: 'Episode'.freeze,
    article: 'Article'.freeze,
    book: 'Book'.freeze,
    thread: 'Threads'.freeze,
  }.freeze

  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :created_by, class_name: 'User'
  belongs_to :resourceable, polymorphic: true
  has_many :votes

  delegate :title,
           :description,
           :url,
           :rss,
           :image,
           to: :resourceable, prefix: false

  accepts_nested_attributes_for :resourceable

  def build_resourceable(params)
    self.resourceable = resourceable_type.constantize.new(params)
  end

  def vote_counted?
    true
  end

  def update_vote_count
    update(vote_count: votes.settled.sum('count'))
    ActionCable.server.broadcast('votes_channel', {resource_id: id, votes: vote_count})
  end
end
