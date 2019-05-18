class Loggedin::AnswersController < ApplicationController
  before_action :set_question, only: %i(create)

  def create
    @answer = @question.answers.build(answer_params) { |answer|
      answer.user = current_user
    }

    if @answer.save
      redirect_to question_url(@question), notice: '回答を投稿しました'
    else
      render 'questions/show'
    end
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:content)
  end
end
