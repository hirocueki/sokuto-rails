class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :name, presence: true

  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :accepted_answers, class_name: 'Answer', dependent: :destroy

  def update_credit_score
    self.with_lock do
      update!(credit_score: calc_credit_score)
    end
  end

  def calc_credit_score
    [
        questions.pluck(:cached_votes_up).inject(0, :+) * 5,
        questions.pluck(:cached_votes_down).inject(0, :+) * -2,
        self.answers.pluck(:accepted).count(true) * 15,
        self.accepted_answers.size * 2,
    ].inject(1, :+)
  end
end
