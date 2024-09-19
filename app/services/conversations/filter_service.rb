class Conversations::FilterService < FilterService
  ATTRIBUTE_MODEL = 'conversation_attribute'.freeze

  def initialize(params, user, filter_account = nil)
    @account = filter_account || Current.account
    super(params, user)
  end

  def perform
    conversation_count, mentioned_count, unattended_count, = count_all_open_conversations

    @conversations = query_builder(@filters['conversations'])
    mine_count, unassigned_count, all_count, = set_count_for_all_conversations
    assigned_count = all_count - unassigned_count

    {
      conversations: conversations,
      count: {
        mine_count: mine_count,
        assigned_count: assigned_count,
        unassigned_count: unassigned_count,
        all_count: all_count,
        conversation_count: conversation_count,
        mentioned_count: mentioned_count,
        unattended_count: unattended_count,
      }
    }
  end

  def count
    @conversations = query_builder(@filters['conversations'])
    @conversations.count
  end

  def base_relation
    @account.conversations.includes(
      :taggings, :inbox, { assignee: { avatar_attachment: [:blob] } }, { contact: { avatar_attachment: [:blob] } }, :team, :messages, :contact_inbox
    )
  end

  def current_page
    @params[:page] || 1
  end

  def filter_config
    {
      entity: 'Conversation',
      table_name: 'conversations'
    }
  end

  def conversations
    @conversations.sort_on_last_activity_at.page(current_page)
  end
end
