class QuestionsController < ApplicationController
  before_action :set_question, only: %i[show]

  impressionist actions: [:show]

  def index
    @query_type = params[:query] || 'newest'
    @questions  = Question.order_by(@query_type)
                      .page(params[:page])
                      .per(params[:page_per])
                      .includes(%i[user tags])
  end

  def show
    @answer = @question.answers.build
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end
end
