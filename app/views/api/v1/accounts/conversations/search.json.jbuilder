json.meta do
  json.mine_count @conversations_count[:mine_count]
  json.unassigned_count @conversations_count[:unassigned_count]
  json.all_count @conversations_count[:all_count]
  json.conversation_count @conversations_count[:conversation_count]
  json.mentioned_count @conversations_count[:mentioned_count]
  json.unattended_count @conversations_count[:unattended_count]
end
json.payload do
  json.array! @conversations do |conversation|
    json.partial! 'api/v1/models/conversation', formats: [:json], conversation: conversation
  end
end
