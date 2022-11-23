# frozen_String_literal: true

class PartnerUsersController < ApplicationController
  before_action :set_partner, only: %i[index create]

  def index
    @users = @partner.profile.users
    @user = User.new(name: '')
  end

  def create
    user = UserInviteService.invite(email: user_params[:email], name: user_params[:name], roles: [Role::PARTNER], resource: @partner.profile)
    user.valid?
    
    respond_to do |format|
      format.turbo_stream do
        if user.errors.none?
          render turbo_stream: [
            turbo_stream.replace("partners/#{@partner.id}/form", partial: 'partner_users/form', locals: { partner: @partner, user: User.new(name: '') }),
            turbo_stream.replace("partners/#{@partner.id}/users", partial: 'partner_users/users', locals: { users: @partner.reload.profile.users, partner: @partner })
          ]
        else
          render turbo_stream: [
            turbo_stream.replace("partners/#{@partner.id}/form", partial: 'partner_users/form', locals: { partner: @partner, user: user }),
          ]
        end
      end
    end
  end

  private

  def set_partner
    @partner = Partner.find(params[:partner_id])
  end

  def user_params
    params.require(:user).permit(:email, :name)
  end


end
