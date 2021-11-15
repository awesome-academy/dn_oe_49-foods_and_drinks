require "rails_helper"

RSpec.describe ProductsController, type: :controller do
  describe "GET #index" do
    let!(:product_1) {FactoryBot.create :product}
    let!(:product_2) {FactoryBot.create :product}

    context "when the user render menu page" do
      before do
        get :index
      end

      it "return product" do
        expect(assigns(:products)).to eq [product_2, product_1]
      end

      it "render template static_pages/menu" do
        expect(response).to render_template "static_pages/menu"
      end
    end

    describe "search product by name" do
      context "when product is found" do
        before do
          get :index, params: {name: product_1.name}
        end

        it "return products" do
          expect(assigns(:products)).to eq [product_1]
        end

        it "render template static_pages/menu" do
          expect(response).to render_template("static_pages/menu")
        end
      end

      context "when product is not found" do
        before do
          get :index, params: {name: "nameinvalid"}
        end

        it "return flash danger" do
          expect(flash[:danger]).to eq I18n.t("menu_page.search_pro_nil")
        end

        it "render template static_pages/menu" do
          expect(response).to render_template("static_pages/menu")
        end
      end
    end
  end

  describe "GET #show" do
    let!(:product) {FactoryBot.create :product}

    context "when product exists" do
      before do
        get :show, params: {id: product.id}
      end

      it "return product" do
        expect(assigns(:product)).to eq product
      end

      it "render template show" do
        expect(response).to render_template :show
      end
    end

    context "when product empty" do
      before do
        get :show, params: {id: Settings.length.digit_negative_1}
      end

      it "return flash danger" do
        expect(flash[:danger]).to eq I18n.t("show_product_fail")
      end

      it "redirect to root_url" do
        expect(response).to redirect_to root_url
      end
    end
  end

  describe "GET #filter" do
    let!(:category_1) {FactoryBot.create :category}
    let!(:product_1) {FactoryBot.create :product, category_id: category_1.id}
    let!(:product_2) {FactoryBot.create :product, category_id: category_1.id}

    context "when product exists" do
      before do
        get :filter, params: {category_id: category_1.id}
      end

      it "return products" do
        expect(assigns(:products)).to eq [product_1, product_2]
      end

      it "render template static_pages/menu" do
        expect(response).to render_template "static_pages/menu"
      end
    end

    context "when product empty" do
      before do
        get :filter, params: {category_id: Settings.length.digit_negative_1}
      end

      it "return flash danger" do
        expect(flash[:danger]).to eq I18n.t("menu_page.filter_category_nil")
      end

      it "render template static_pages/menu" do
        expect(response).to render_template "static_pages/menu"
      end
    end
  end
end
