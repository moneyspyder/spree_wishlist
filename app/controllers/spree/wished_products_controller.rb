class Spree::WishedProductsController < Spree::StoreController
  load_and_authorize_resource
  respond_to :html

  def create
    @wished_product = Spree::WishedProduct.new(wished_product_attributes)
    @wishlist = spree_current_user.wishlist

    if @wishlist.include? params[:wished_product][:variant_id]
      @wished_product = @wishlist.wished_products.detect { |wp| wp.variant_id == params[:wished_product][:variant_id].to_i }
    else
      @wished_product.wishlist = spree_current_user.wishlist
      @wished_product.save
    end

    respond_with(@wished_product) do |format|
      format.html { redirect_to wishlist_url(@wishlist) }
    end
  end

  def update
    @wished_product = Spree::WishedProduct.find(params[:id])
    @wished_product.update_attributes(wished_product_attributes)

    respond_with(@wished_product) do |format|
      format.html { redirect_to wishlist_url(@wished_product.wishlist) }
    end
  end

  def destroy
    @wished_product = Spree::WishedProduct.find(params[:id])
    @wished_product.destroy

    respond_with(@wished_product) do |format|
      format.html { redirect_to wishlist_url(@wished_product.wishlist) }
    end
  end

  private

  def wished_product_attributes
    params.require(:wished_product).permit(:variant_id, :wishlist_id, :remark, :quantity)
  end

  def store_location
    # redirect back to product page after non-loged in user sign in
    if request.fullpath.gsub('//', '/') == '/wished_products' && params["wished_product"]
      variant = Spree::Variant.find_by_id(params["wished_product"]["variant_id"])
      if variant
        session['spree_user_return_to'] = spree.product_path(variant.product)
      else
        flash[:alert] = "Product variant not found"
        session['spree_user_return_to'] = '/'
      end
    end
  end
end
