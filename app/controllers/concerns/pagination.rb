module Pagination
  def paginate(collection, page: 1, per_page: 10)
    page = page.to_i < 1 ? 1 : page.to_i
    total_items = collection.count
    total_pages = (total_items.to_f / per_page).ceil
    paginated_collection = collection.offset((page - 1) * per_page).limit(per_page)

    {
      collection: paginated_collection,
      total_items: total_items,
      total_pages: total_pages,
      current_page: page,
      per_page: per_page,
      prev_page: page > 1 ? page - 1 : nil,
      next_page: page < total_pages ? page + 1 : nil
    }
  end
end

