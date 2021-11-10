require "rails_helper"
include SessionsHelper

RSpec.describe UsersController, type: :controller do
  describe "GET #new" do
    subject {get :new}

    context "when user unlogged" do
      it "render new" do
        expect(subject).to render_template(:new)
      end
      it "do not render different template" do
        expect(subject).to_not render_template(:show)
      end
    end

    context "when user is logged" do
      before do
        user = FactoryBot.create :user
        log_in user
      end
      it "redirect to the root_url" do
        expect(subject).to redirect_to root_url
      end
    end
  end

  describe "POST #create" do
    context "when valid strong params" do
      before do
        post :create, params: { user: {
          name: Faker::Name.name,
          email: "thang@gmail.com",
          password: "123456789",
          password_confirmation: "123456789"
        }}
      end

      it "display flash success" do
        expect(flash.now[:success]).to eq I18n.t("sign_up.message_sign_up_success")
      end

      it "redirect to the root_url" do
        expect(response).to redirect_to root_url
      end
    end

    context "when invalid strong params" do
      before do
        post :create, params: { user: { name: ""}}
      end

      it "display flash danger" do
        expect(flash.now[:danger]).to eq I18n.t("sign_up.message_sign_up_fail")
      end

      it "render new" do
        expect(response).to render_template :new
      end
    end
  end
end
