require "rails_helper"

RSpec.describe ProductsController, type: :controller do
  describe "GET /show" do
    let!(:product) { FactoryBot.create :product }
    context "when product exist" do
      before do
        get :show, params: {id: product.id}
      end
      it "return product" do
        expect(assigns(:product)).to eq product
      end

      it "render :show product" do
        expect(response).to render_template(:show)
      end
    end

    context "when product not found" do
      before do
        get :show, params: {id: -1}
      end
      it "display flash danger when product not found" do
        expect(flash[:danger]).to eq I18n.t("show_product_fail")
      end
      it "redirect root page when product not found" do
        expect(response).to redirect_to root_url
      end
    end
  end

  describe "GET /filter" do
    let!(:category_1) { FactoryBot.create :category}
    let!(:product_1) { FactoryBot.create :product, status: "enabled",
                                         category_id: category_1.id }
    let!(:product_2) { FactoryBot.create :product, status: "enabled",
                                         category_id: category_1.id }
    let!(:product_3) { FactoryBot.create :product, status: "enabled"}
    context "when product any" do
      before do
        get :filter, params: {category_id: category_1.id}
      end
      it "return product" do
        expect(assigns(:products)).to eq [product_1, product_2]
      end
    end

    context "when product empty" do
      before do
        get :filter, params: {category_id: -1}
      end
      it "display flash danger when product empty" do
        expect(flash[:danger]).to eq I18n.t("menu_page.filter_category_nil")
      end

      it "redirect static_pages/menu when product empty" do
        expect(response).to render_template "static_pages/menu"
      end
    end
  end

  describe "GET /index" do
    let!(:product_1) { FactoryBot.create :product, name: "Tra Sua", status: "enabled"}
    let!(:product_2) { FactoryBot.create :product, name: "Tra Sua", status: "enabled" }
    let!(:product_3) { FactoryBot.create :product, status: "enabled"}
    describe "index product" do
      before do
        get :index
      end

      it "return products" do
        expect(assigns(:products)).to eq [product_3, product_2, product_1]
      end

      it "render :index product" do
        expect(response).to render_template "static_pages/menu"
      end
    end
    describe "search product" do
      context "when product exits" do
        before do
          get :index, params: {name: "Tra Sua"}
        end

        it "return product_1" do
          expect(assigns(:products)).to eq [product_2, product_1]
        end

        it "render static_pages/menu" do
          expect(response).to render_template "static_pages/menu"
        end
      end

      context "when product not exits" do
        before do
          get :index, params: {name: "namekhongtontai"}
        end

        it "display flash danger when @products empty" do
          expect(flash[:danger]).to eq I18n.t("menu_page.search_pro_nil")
        end

        it "render static_pages/menu" do
          expect(response).to render_template "static_pages/menu"
        end
      end
    end
  end
end
