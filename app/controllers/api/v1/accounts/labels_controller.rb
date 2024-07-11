class Api::V1::Accounts::LabelsController < Api::V1::Accounts::BaseController
  before_action :current_account
  before_action :fetch_label, except: [:index, :create]
  before_action :check_authorization

  def index
    @labels = policy_scope(Current.account.labels)
    add_meta
  end

  def show; end

  def create
    @label = Current.account.labels.create!(permitted_params)
  end

  def update
    @label.update!(permitted_params)
  end

  def destroy
    @label.destroy!
    head :ok
  end

  private

  def fetch_label
    @label = Current.account.labels.find(params[:id])
  end

  def permitted_params
    params.require(:label).permit(:title, :description, :color, :show_on_sidebar)
  end

  def add_meta
    return @labels unless params[:meta].presence
    @labels.each do |label|
      label[:meta] = { :count => 0 }
      label[:meta][:count] = ConversationFinder.new(Current.user, {
        :labels => label[:title], 
        :status => "open"
      }).count_label
    end
  end
end
