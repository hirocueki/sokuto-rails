class Question < ApplicationRecord
  paginates_per 10

  acts_as_ordered_taggable
  acts_as_votable
  is_impressionable :counter_cache => true

  validates :title, presence: true

  belongs_to :user
  has_many :answers, dependent: :destroy

  scope :recent, -> {
    order(created_at: :desc)
  }
  scope :no_answers, -> {
    where(answers_count: 0)
  }

  scope :in_week, -> {
    where(created_at: 1.week.ago.beginning_of_day..Time.zone.now.end_of_day)
  }

  scope :in_month, -> {
    where(created_at: 1.month.ago.beginning_of_day..Time.zone.now.end_of_day)
  }

  scope :filter_by, ->(filter) {
    case filter
    when 'in_week'
      in_week.recent
    when 'in_month'
      in_month.recent
    end
  }

  scope :order_by, ->(type) {
    case type
    when 'no_answer'
      no_answers.order(created_at: :asc)
    when 'votes'
      order(cached_votes_score: :desc)
    when 'popular'
      order('(cached_weighted_score + impressions_count + answers_count) DESC')
    end
  }

  def truncated_content
    content.truncate(40)
  end

  def persisted_answers
    answers.where.not(id: nil).includes(:user).order(:created_at)
  end

  def popular_score
    answers_count + impressions_count + cached_weighted_score
  end

  def up_vote_by(user)
    Question.transaction do
      self.upvote_by user
      self.user.update_credit_score
    end
  end

  def down_vote_by(user)
    Question.transaction do
      self.downvote_by user
      self.user.update_credit_score
    end
  end
end
