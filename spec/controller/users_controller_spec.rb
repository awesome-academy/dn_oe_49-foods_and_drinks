require "rails_helper"
include SessionsHelper

RSpec.describe UsersController, type: :controller do
  describe "GET #new" do
    subject {get :new}

    context "when the user unlogged" do
      it "render template new" do
        expect(subject).to render_template(:new)
      end
    end

    context "when the user is logged" do
      before do
        user = FactoryBot.create(:user)
        log_in user
      end

      it "redirect to root_url" do
        expect(subject).to redirect_to root_url
      end
    end
  end

  describe "POST #create" do
    context "with valid params" do
      before do
        post :create, params: { user: {
          name: Faker::Name.name,
          email: Faker::Internet.email.downcase,
          password: "password",
          password_confirmation: "password"
        }}
      end

      it "return flash success" do
        expect(flash[:success]).to eq I18n.t("sign_up.message_sign_up_success")
      end

      it "redirect to root_url" do
        expect(response).to redirect_to root_url
      end
    end

    context "with invalid params" do
      before do
        post :create, params: { user: {
          name: "",
          email: "",
          password: "password",
          password_confirmation: "password123"
        }}
      end

      it "return flash danger" do
        expect(flash[:danger]).to eq I18n.t("sign_up.message_sign_up_fail")
      end

      it "render template new" do
        expect(response).to render_template(:new)
      end
    end
  end
end
