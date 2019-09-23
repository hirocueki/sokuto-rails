class Tag < ActsAsTaggableOn::Tag
  paginates_per 12

  extend OrderAsSpecified

  scope :order_by, ->(type) {
    case type
    when 'new'
      # 質問の作成日順に
      newer_tag_ids = Question.newer_tag_ids
      Tag.order_as_specified(id: newer_tag_ids)

    when 'name'
      order(name: :asc)
    else
      most_used
    end
  }
end
