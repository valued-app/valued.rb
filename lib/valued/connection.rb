class Valued::Connection
  ENDPOINT = "https://events.valued.app/integrations/custom"
  OFFICIAL_KEYS = %i[user_id account_id]
  private_constant :ENDPOINT

  def initialize(project_id:, token:, endpoint: ENDPOINT)
    @executer   = Concurrent::SingleThreadExecutor.new
    @endpoint   = URI(ENDPOINT)
    @token      = token
    @project_id = project_id
  end

  def scope(**data) = Scope.new(self, **data)
  
  def track(event, **data)
    payload = {
      project_id: @project_id,
      created_at: Time.now.to_i,
      event:      event,
      data:       data.except(*OFFICIAL_KEYS),
      **data.slice(*OFFICIAL_KEYS),
    }
    @executer <<-> { send(payload) }
  end

  private

  def send(payload)
    Net::HTTP.post(@endpoint, payload.to_json,
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{@token}")
  end
end