class Api::V1::Accounts::TeamsController < Api::V1::Accounts::BaseController
  before_action :fetch_team, only: [:show, :update, :destroy]
  before_action :check_authorization

  def index
    @teams = Current.account.teams
    add_meta
  end

  def show; end

  def create
    @team = Current.account.teams.new(team_params)
    @team.save!
  end

  def update
    @team.update!(team_params)
  end

  def destroy
    @team.destroy!
    head :ok
  end

  private

  def fetch_team
    @team = Current.account.teams.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :description, :allow_auto_assign)
  end

  def add_meta
    return @teams unless params[:meta].presence
    @teams.each do |team|
      team[:meta] = { :count => 0 }
      team[:meta][:count] = ConversationFinder.new(Current.user, {
        :team_id => team[:id], 
        :status => "open"
      }).count_team
    end
  end
end
