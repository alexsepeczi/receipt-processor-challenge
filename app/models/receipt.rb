# frozen_string_literal: true

# Core receipt object
class Receipt < Object
  attr_accessor :id, :points

  # This object will be the base object for the receipt. Will take in the following params and hold one calculated
  # attribute named points. For now, this object will only need to be able to handle
  # 1. creating a receipt with the correct amount of points that has a unique id to be used on retrieval
  # @param retailer [Sting] the retailer name. Will ignore if nil
  # @param purchaseDate [Sting] date of purchase. Will ignore if nil or invalid
  # @param purchaseTime [Sting] time of purchase. Will ignore if nil or invalid
  # @param items [Array<Hash>] is hash formatted with attributes :shortDescription and :price
  # @param total [String] total cost from the receipt. Will ignore if nil.
  # @return [Receipt]
  def initialize(retailer: nil, purchaseDate: nil, purchaseTime: nil, items: nil, total: nil)
    @id = SecureRandom.uuid
    @retailer = retailer
    @purchase_date = purchaseDate&.to_date
    @purchase_time = purchaseTime&.to_time
    @items = items
    # Hate floats but won't get into money configuration for the sake of simplicity
    @total = total.to_f if total

    @points = calculate_points || 0
  end

  private

  # Doing this procedurally due simplicity
  def calculate_points
    points = 0

    points += @retailer&.scan(/[[:alnum:]]/)&.size || 0

    if @total
      points += 50 if @total - @total.round(0) < 0.01

      points += 25 if @total % 0.25 == 0
    end

    points += (@items.length / 2) * 5 if @items

    @items&.each do |item|
      next unless item[:shortDescription].is_a?(String) && item[:price]

      points += (item[:price].to_f * 0.2).round(2).ceil if item[:shortDescription].strip.length % 3 == 0
    end

    points += 6 if @purchase_date && @purchase_date.day.odd?

    points += 10 if ('14:00'.to_time...'16:00'.to_time).cover?(@purchase_time) && @purchase_time != '14:00'.to_time

    points
  end
end
