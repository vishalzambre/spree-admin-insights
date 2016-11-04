module Spree
  class SalesReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :completed_at_date
    HEADERS = {
        order_number: :string,
        completed_at_date: :string,
        completed_at_time: :string,
        item_total: :integer,
        shipment_total: :integer,
        total_before_additional_tax: :integer,
        additional_tax_total: :integer,
        total_after_additional_tax: :integer,
        adjustment_total: :integer,
        total_after_adjustments: :integer,
        promotion_code: :string,
        buyer_name: :string,
        buyer_gender: :string,
        buyer_age: :integer,
        buyer_zipcode: :string,
        product_taxons: :string,
        product_sku: :string,
        product_name: :string,
        line_item_quantity: :integer,
        line_item_price: :integer,
        line_item_total: :integer
    }
    SEARCH_ATTRIBUTES = {start_date: :orders_completed_from, end_date: :orders_completed_to}
    SORTABLE_ATTRIBUTES = [
        :order_number,
        :completed_at_date,
        :completed_at_time,
        :item_total,
        :shipment_total,
        :total_before_additional_tax,
        :additional_tax_total,
        :total_after_additional_tax,
        :adjustment_total,
        :total_after_adjustments,
        :promotion_code,
        :buyer_name,
        :buyer_gender,
        :buyer_age,
        :buyer_zipcode,
        :product_taxons,
        :product_sku,
        :product_name,
        :line_item_quantity,
        :line_item_price,
        :line_item_total
    ]

    def initialize(options)
      super
      @sortable_type = :desc if options[:sort].blank?
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
    end

    def generate
      products_with_taxons = ::SpreeAdminInsights::ReportDb[:spree_products___products].
          left_join(:spree_products_taxons___products_taxons,
                    products__id: :products_taxons__product_id).
          left_join(:spree_taxons___taxons,
                    taxons__id: :products_taxons__taxon_id).
          group(:products__id, :products__name).
          select do
        [
            Sequel.as(:products__id, :id),
            Sequel.as(:products__name, :name),
            Sequel.as(Sequel.function(:string_agg, :taxons__name, ', '), :taxons)
        ]
      end

      ::SpreeAdminInsights::ReportDb[:spree_orders___orders].
          where(orders__completed_at: @start_date..@end_date).
          where(orders__state: 'complete').
          where(orders__payment_state: 'paid').
          where(orders__shipment_state: 'ready').
          left_join(:spree_line_items___line_items,
                    line_items__order_id: :orders__id).
          left_join(:spree_adjustments___adjustments,
                    adjustments__adjustable_type: 'Spree::Order',
                    adjustments__order_id: :orders__id,
                    adjustments__source_type: 'Spree::PromotionAction',
                    adjustments__eligible: true).
          left_join(:spree_promotions___promotions,
                    promotions__id: :adjustments__source_id).
          left_join(:spree_variants___variants,
                    variants__id: :line_items__variant_id).
          left_join(products_with_taxons.as(:products),
                    products__id: :variants__product_id).
          left_join(:spree_addresses___addresses,
                    addresses__id: :orders__ship_address_id).
          left_join(:spree_users___users,
                    users__id: :orders__user_id).
          left_join(:spree_profiles___profiles,
                    profiles__user_id: :users__id).
          order(sortable_sequel_expression)
    end

    def select_columns(dataset)
      dataset.select do
        [
            Sequel.as(:orders__number,
                      :order_number),
            Sequel.as(Sequel.cast(:orders__completed_at, :date),
                      :completed_at_date),
            Sequel.as(Sequel.function(:date_trunc, 'second', Sequel.cast(:orders__completed_at, :time)),
                      :completed_at_time),
            Sequel.as(:orders__item_total,
                      :item_total),
            Sequel.as(:orders__shipment_total,
                      :shipment_total),
            Sequel.as(Sequel.expr(:orders__item_total) + :orders__shipment_total,
                      :total_before_additional_tax),
            Sequel.as(:orders__additional_tax_total,
                      :additional_tax_total),
            Sequel.as(Sequel.expr(:orders__item_total) + :orders__shipment_total + :orders__additional_tax_total,
                      :total_after_additional_tax),
            Sequel.as(:orders__adjustment_total,
                      :adjustment_total),
            Sequel.as(Sequel.expr(:orders__item_total) + :orders__shipment_total + :orders__additional_tax_total + :orders__adjustment_total,
                      :total_after_adjustments),
            Sequel.as(:promotions__code,
                      :promotion_code),
            Sequel.as(Sequel.function(:concat, :addresses__firstname, ' ', :addresses__lastname),
                      :buyer_name),
            Sequel.as(Sequel.case({'1' => 'F', '2' => 'M'}, nil, :profiles__gender),
                      :buyer_gender),
            Sequel.as(Sequel.extract(:year, Sequel.function(:age, Sequel.function(:now), :profiles__date_of_birth)),
                      :buyer_age),
            Sequel.as(:addresses__zipcode,
                      :buyer_zipcode),
            Sequel.as(:products__taxons,
                      :product_taxons),
            Sequel.as(:variants__sku,
                      :product_sku),
            Sequel.as(:products__name,
                      :product_name),
            Sequel.as(:line_items__quantity,
                      :line_item_quantity),
            Sequel.as(:line_items__price,
                      :line_item_price),
            Sequel.as(Sequel.expr(:line_items__price) * :line_items__quantity,
                      :line_item_total)
        ]
      end
    end
  end
end
