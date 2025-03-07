require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe QueryResultsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # QueryResult. As you add validations to QueryResult, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # QueryResultsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all query_results as @query_results" do
      query_result = QueryResult.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:query_results)).to eq([query_result])
    end
  end

  describe "GET #show" do
    it "assigns the requested query_result as @query_result" do
      query_result = QueryResult.create! valid_attributes
      get :show, {:id => query_result.to_param}, valid_session
      expect(assigns(:query_result)).to eq(query_result)
    end
  end

  describe "GET #new" do
    it "assigns a new query_result as @query_result" do
      get :new, {}, valid_session
      expect(assigns(:query_result)).to be_a_new(QueryResult)
    end
  end

  describe "GET #edit" do
    it "assigns the requested query_result as @query_result" do
      query_result = QueryResult.create! valid_attributes
      get :edit, {:id => query_result.to_param}, valid_session
      expect(assigns(:query_result)).to eq(query_result)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new QueryResult" do
        expect {
          post :create, {:query_result => valid_attributes}, valid_session
        }.to change(QueryResult, :count).by(1)
      end

      it "assigns a newly created query_result as @query_result" do
        post :create, {:query_result => valid_attributes}, valid_session
        expect(assigns(:query_result)).to be_a(QueryResult)
        expect(assigns(:query_result)).to be_persisted
      end

      it "redirects to the created query_result" do
        post :create, {:query_result => valid_attributes}, valid_session
        expect(response).to redirect_to(QueryResult.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved query_result as @query_result" do
        post :create, {:query_result => invalid_attributes}, valid_session
        expect(assigns(:query_result)).to be_a_new(QueryResult)
      end

      it "re-renders the 'new' template" do
        post :create, {:query_result => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested query_result" do
        query_result = QueryResult.create! valid_attributes
        put :update, {:id => query_result.to_param, :query_result => new_attributes}, valid_session
        query_result.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested query_result as @query_result" do
        query_result = QueryResult.create! valid_attributes
        put :update, {:id => query_result.to_param, :query_result => valid_attributes}, valid_session
        expect(assigns(:query_result)).to eq(query_result)
      end

      it "redirects to the query_result" do
        query_result = QueryResult.create! valid_attributes
        put :update, {:id => query_result.to_param, :query_result => valid_attributes}, valid_session
        expect(response).to redirect_to(query_result)
      end
    end

    context "with invalid params" do
      it "assigns the query_result as @query_result" do
        query_result = QueryResult.create! valid_attributes
        put :update, {:id => query_result.to_param, :query_result => invalid_attributes}, valid_session
        expect(assigns(:query_result)).to eq(query_result)
      end

      it "re-renders the 'edit' template" do
        query_result = QueryResult.create! valid_attributes
        put :update, {:id => query_result.to_param, :query_result => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested query_result" do
      query_result = QueryResult.create! valid_attributes
      expect {
        delete :destroy, {:id => query_result.to_param}, valid_session
      }.to change(QueryResult, :count).by(-1)
    end

    it "redirects to the query_results list" do
      query_result = QueryResult.create! valid_attributes
      delete :destroy, {:id => query_result.to_param}, valid_session
      expect(response).to redirect_to(query_results_url)
    end
  end

end
