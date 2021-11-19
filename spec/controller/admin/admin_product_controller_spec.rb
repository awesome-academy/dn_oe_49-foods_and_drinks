require "rails_helper"
include SessionsHelper
RSpec.describe Admin::ProductsController, type: :controller do
  describe "GET #index" do
    context "when user login is admin" do
      before do
        @user = FactoryBot.create :user, role: 1
        sign_in @user
      end
      context "asset method index" do
        let!(:product_1) { FactoryBot.create :product}
        let!(:product_2) { FactoryBot.create :product}
        let!(:product_3) { FactoryBot.create :product}
        before { get :index }
        it "assigns products" do
          expect(assigns(:products)).to eq ([product_3, product_2, product_1])
        end

        it "render the index template" do
          expect(response).to render_template(:index)
        end
      end
    end

    context "when user login isn't admin" do
      before do
        @user = FactoryBot.create :user
        sign_in @user
      end
      context "asset method index" do
        before { get :index }
        it "render the root_path" do
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context "when user not login" do
      before do
        get :index, params: {locale: "vi"}
      end
      it "redirects to login" do
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "GET #show" do
    context "when user login is admin" do
      before do
        @user = FactoryBot.create :user, role: 1
        sign_in @user
      end
      context "when product exist" do
        let!(:product_1) { FactoryBot.create :product}
        before do
          get :show, params: {id: product_1.id}
        end
        it "assigns product_1" do
          expect(assigns(:product)).to eq (product_1)
        end

        it "render template show" do
          expect(response).to render_template(:show)
        end
      end
    end

    context "when user login is not admin" do
      before do
        @user = FactoryBot.create :user
        sign_in @user
      end
      context "asset method show" do
        let!(:product_1) { FactoryBot.create :product}
        before do
          get :show, params: {id: product_1.id}
        end
        it "redirects to root_path" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when user not login" do
      let!(:product_1) { FactoryBot.create :product}
      before do
        get :show, params: {locale: "vi", id: product_1.id}
      end
      it "redirects to login" do
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "GET #new" do
    context "when user login is admin" do
      before do
        @user = FactoryBot.create :user, role: 1
        sign_in @user
      end
      context "asset method new" do
        before { get :new }
        subject { response }
        it { is_expected.to render_template :new }
      end
    end

    context "when user login is not admin" do
      before do
        @user = FactoryBot.create :user
        sign_in @user
      end
      context "asset method new" do
        before { get :new }
        it "redirects to root_path" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when user not login" do
      before do
        get :new, params: {locale: "vi"}
      end
      it "redirects to login" do
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "GET #edit" do
    context "when user login is admin" do
      before do
        @user = FactoryBot.create :user, role: 1
        sign_in @user
      end
      context "when product exist" do
        let!(:product_1) { FactoryBot.create :product}
        before do
          get :edit, params: {id: product_1.id}
        end
        it "assigns product_1" do
          expect(assigns(:product)).to eq (product_1)
        end

        it "render template edit" do
          expect(response).to render_template(:edit)
        end
      end
    end

    context "when user login is not admin" do
      before do
        @user = FactoryBot.create :user
        sign_in @user
      end
      context "asset method edit" do
        let!(:product_1) { FactoryBot.create :product}
        before do
          get :edit, params: {id: product_1.id}
        end
        it "redirects to root_path" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when user not login" do
      let!(:product_1) { FactoryBot.create :product}
      before do
        get :edit, params: {locale: "vi", id: product_1.id}
      end
      it "redirects to login" do
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "POST #update" do
    context "when user login is admin" do
      before do
        @user = FactoryBot.create :user, role: 1
        sign_in @user
      end
      context "success when valid attributes" do
        before do
          @product = FactoryBot.create :product
          put :update, params: {
            product: {name: "ThangNT"},
            id: @product.id
          }
          @product.reload
        end
        it "update db success" do
          expect([@product.name]).to eq(["ThangNT"])
        end

        it "display flash success" do
          expect(flash[:success]).to eq I18n.t("update_product.msg_update_success")
        end

        it "redirects to admin_product" do
          expect(response).to redirect_to admin_product_path
        end
      end

      context "fail when invalid attributes" do
        before do
          @product = FactoryBot.create :product
          put :update, params: {
            product: {name: ""},
            id: @product.id
          }
        end
        it "display flash danger" do
          expect(flash[:danger]).to eq I18n.t("update_product.msg_update_fail")
        end

        it "render template edit" do
          expect(response).to render_template :edit
        end
      end
    end

    context "when user login is not admin" do
      before do
        @user = FactoryBot.create :user
        sign_in @user
      end
      context "asset method update" do
        before do
          @product = FactoryBot.create :product
          put :update, params: { id: @product.id }
        end
        it "redirects to root_path" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when user not login" do
      before do
        @product = FactoryBot.create :product
        put :update, params: {locale: "vi", id: @product.id }
      end
      it "redirects to login" do
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "POST #create" do
    context "when user login is admin" do
      before do
        @user = FactoryBot.create :user, role: 1
        sign_in @user
      end
      context "when valid strong params" do
        let!(:category_1) { FactoryBot.create :category }
        before do
          post :create, params: { product: {
            name: Faker::Name.name,
            price: 20000,
            description: Faker::Food.description,
            quantity: 5,
            category_id: category_1.id}
          }
        end

        it "display flash info" do
          expect(flash[:info]).to eq I18n.t("product_controller.msg_create_success")
        end

        it "redirect to the admin_product_path" do
          expect(response).to redirect_to admin_product_url(23)
        end
      end

      context "when invalid strong params" do
        before do
          post :create, params: { product: { name: ""}}
        end

        it "display flash danger" do
          expect(flash[:danger]).to eq I18n.t("product_controller.msg_create_fail")
        end

        it "render template new" do
          expect(response).to render_template :new
        end
      end
    end

    context "when user login is not admin" do
      before do
        @user = FactoryBot.create :user
        sign_in @user
      end
      context "asset method update" do
        before do
          post :create
        end
        it "redirects to root_path" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when user not login" do
      before do
        post :create, params: {locale: "vi"}
      end
      it "redirects to login" do
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "DELETE #destroy" do
    context "when user login is admin" do
      before do
        @user = FactoryBot.create :user, role: 1
        sign_in @user
      end
      context "when product exist" do
        let!(:product_1) { FactoryBot.create :product}
        before do
          delete :destroy, params: {id: product_1.id}
        end
        it "assigns product_1" do
          expect(assigns(:product)).to eq (product_1)
        end

        context "when product exist in order" do
          context "when status product = enabled " do
            before do
              @product_1 = FactoryBot.create :product, status: "enabled"
              put :update, params: {
                product: {status: "disabled"},
                id: @product_1.id
              }
              @product_1.reload
            end

            it "update status product success" do
              expect([@product_1.status]).to eq(["disabled"])
            end

            it "display flash success" do
              expect(flash[:success]).to eq I18n.t("update_product.msg_update_success")
            end

            it "redirect to admin products" do
              expect(response).to redirect_to admin_product_path
            end
          end

          context "when status product = disabled " do
            before do
              @product_2 = FactoryBot.create :product, status: "disabled"
            end

            it "redirect to admin products" do
              expect(response).to redirect_to admin_products_path
            end
          end
        end
      end
      context "when product not exist in order" do
        before do
          @product = FactoryBot.create :product
          delete :destroy, params: { id: @product.id }
        end

        it "delete success" do
          expect(Product.all.include?(@product.id)).to eq false
        end

        it "display flash success" do
          expect(flash[:success]).to eq I18n.t("product_controller.msg_delete_success")
        end
      end
    end

    context "when user login is not admin" do
      before do
        @user = FactoryBot.create :user
        sign_in @user
      end
      context "asset method update" do
        before do
          @product = FactoryBot.create :product
          delete :destroy, params: {id: @product.id}
        end
        it "redirects to root_path" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when user not login" do
      before do
        @product = FactoryBot.create :product
        delete :destroy, params: {locale: "vi", id: @product.id}
      end
      it "redirects to login" do
        expect(response).to redirect_to new_user_session_url
      end
    end
  end
end
