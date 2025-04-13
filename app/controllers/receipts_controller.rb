# frozen_string_literal: true

# Controller to handle receipt processing
class ReceiptsController < ApplicationController
  before_action :set_receipt, only: :show

  def create
    receipt = Receipt.new(**receipt_params)

    Rails.cache.write(receipt.id, receipt)

    render json: { id: receipt.id }, status: :ok
  end

  def show
    render json: { points: @receipt.points }, status: :ok
  end

  ## 404 Not Found
  rescue_from Errors::NotFoundError do |_e|
    render json: { errors: [{ code: 'not_found', message: 'No receipt found for that ID.' }] }, status: :not_found
  end

  ## 400 Bad Request
  rescue_from Errors::BadRequest, Date::Error do |_|
    render json: { errors: [{ code: 'bad_request', message: 'The receipt is invalid.' }] },
           status: :bad_request
  end

  private

  def receipt_params
    params.permit(:retailer, :purchaseDate, :purchaseTime, :total, items: %i[shortDescription price])
          .to_h.deep_symbolize_keys
  end

  def set_receipt
    @receipt = Rails.cache.read(params[:id]) || raise(Errors::NotFoundError, 'Receipt not found')
  end
end
