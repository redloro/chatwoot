json.array! @agent_bots do |agent_bot|
  json.partial! 'api/v1/models/agent_bot', formats: [:json], resource: AgentBotPresenter.new(agent_bot)
end
